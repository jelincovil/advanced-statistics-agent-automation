#!/usr/bin/env python3
"""
chat_simple.py - Interfaz de terminal avanzada para el Agente de Diagnóstico Médico.

Utiliza la persistencia de LangGraph (MemorySaver) para manejar correctamente las
interrupciones (Human-in-the-loop) basadas en la incertidumbre estadística
(Teoría de Decisión de Wald / modelo Beta-Bernoulli).
"""

import os
import sys
import uuid
from typing import Any, Dict, List

# Añadir el directorio actual al path para importar agent.py
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from langgraph.checkpoint.memory import MemorySaver
    from langgraph.types import Command

    from agent import builder
except ImportError as e:
    print(f"❌ Error al importar módulos: {e}")
    print("Asegúrate de que agent.py esté en el mismo directorio y LangGraph esté instalado.")
    sys.exit(1)

# =====================================================================
# CONFIGURACIÓN DEL GRAFO CON MEMORIA
# =====================================================================
memory = MemorySaver()
graph = builder.compile(checkpointer=memory)

thread_id = str(uuid.uuid4())
config = {"configurable": {"thread_id": thread_id}}

# Estado global de sesión (solo para presentación, la fuente de verdad es el grafo)
historial_observaciones: List[int] = []
num_intervenciones_medico: int = 0


# =====================================================================
# COLORES Y UTILIDADES DE TERMINAL
# =====================================================================
class C:
    """Códigos ANSI de color y estilo."""
    HEADER  = "\033[95m"
    BLUE    = "\033[94m"
    CYAN    = "\033[96m"
    GREEN   = "\033[92m"
    YELLOW  = "\033[93m"
    RED     = "\033[91m"
    ENDC    = "\033[0m"
    BOLD    = "\033[1m"
    DIM     = "\033[2m"


def _limpiar_pantalla():
    os.system("clear" if os.name == "posix" else "cls")


def _linea(char: str = "─", ancho: int = 65, color: str = C.BLUE) -> str:
    return color + char * ancho + C.ENDC


def _titulo(texto: str, color: str = C.HEADER) -> str:
    return color + C.BOLD + texto + C.ENDC


# =====================================================================
# COMPONENTES DE PANTALLA
# =====================================================================
def mostrar_banner():
    """Banner inicial del sistema."""
    _limpiar_pantalla()
    print(_linea("═", color=C.HEADER))
    print(_titulo(" 🏥  SISTEMA DE DIAGNÓSTICO BAYESIANO  ─  Beta-Bernoulli"))
    print(_linea("═", color=C.HEADER))
    print(f" {C.CYAN}Modelo{C.ENDC}   :  Beta(α, β)  →  prior conjugado para Bernoulli")
    print(f" {C.CYAN}Parada{C.ENDC}   :  Regla de Wald  →  σ_post < ε")
    print(f" {C.CYAN}Humano{C.ENDC}   :  Intervención médica si σ_post ≥ ε")
    print(_linea("─"))


def _barra_convergencia(sigma: float, umbral: float, ancho: int = 30) -> str:
    """
    Barra visual que muestra qué tan cerca está sigma del umbral.
    Rellena de derecha a izquierda: cuando sigma → 0 la barra está completa.
    """
    # Clampear entre 0 y 1 para visualización
    progreso = max(0.0, min(1.0, 1.0 - (sigma / max(umbral * 4, sigma + 1e-9))))
    llenos = int(progreso * ancho)
    vacios = ancho - llenos

    color = C.GREEN if sigma < umbral else C.YELLOW
    barra = color + "█" * llenos + C.DIM + "░" * vacios + C.ENDC
    return f"[{barra}]"


def _historial_visual(obs: List[int]) -> str:
    """Representación compacta del historial de observaciones."""
    if not obs:
        return C.DIM + "(sin observaciones aún)" + C.ENDC
    tokens = []
    for o in obs:
        if o == 1:
            tokens.append(C.RED + "●" + C.ENDC)       # positivo
        else:
            tokens.append(C.GREEN + "○" + C.ENDC)     # negativo
    return " ".join(tokens)


def mostrar_dashboard(estado: Dict[str, Any]):
    """Panel de control estadístico completo."""
    alpha  = estado.get("alpha", 1)
    beta   = estado.get("beta", 1)
    sigma  = estado.get("sigma_post", 1.0)
    umbral = estado.get("umbral_incertidumbre", 0.05)
    c      = estado.get("c", 1.0)
    d_val  = estado.get("d", 1.0)
    n      = len(historial_observaciones)
    pos    = sum(historial_observaciones)
    neg    = n - pos

    media_post   = alpha / (alpha + beta) if (alpha + beta) > 0 else 0.5
    umbral_bayes = d_val / (c + d_val) if (c + d_val) > 0 else 0.5

    confianza_ok = sigma < umbral
    tratar       = media_post > umbral_bayes
    estado_label = (
        C.GREEN + "✅  CONFIANZA ÓPTIMA" + C.ENDC
        if confianza_ok
        else C.YELLOW + "⚠️  ALTA INCERTIDUMBRE" + C.ENDC
    )
    sigma_color    = C.GREEN if confianza_ok else C.YELLOW
    decision_color = C.RED   if tratar       else C.GREEN
    decision_label = "TRATAR" if tratar else "NO TRATAR"

    print("\n" + _titulo("  📊  PANEL DE ESTADO ESTADÍSTICO"))
    print(_linea("─", 55))
    print(f"  Distribución posterior : Beta({alpha}, {beta})")
    print(f"  E[θ]  (prob. patología): {C.BOLD}{media_post:.4f}{C.ENDC}"
          f"  umbral d/(c+d) = {umbral_bayes:.4f}")
    print(f"  Decisión bayesiana     : {decision_color}{C.BOLD}{decision_label}{C.ENDC}"
          f"  (c={c:.1f}, d={d_val:.1f})")
    print(
        f"  σ_post (incertidumbre) : {sigma_color}{C.BOLD}{sigma:.4f}{C.ENDC}"
        f"  umbral ε = {umbral}"
    )
    print(
        f"  Convergencia           : {_barra_convergencia(sigma, umbral)}"
        f"  {'→ PARAR' if confianza_ok else '→ más pruebas'}"
    )
    print(_linea("─", 55))
    print(f"  Pruebas realizadas     : {C.BOLD}{n}{C.ENDC}"
          f"  ({C.RED}●{C.ENDC} {pos} pos  /  {C.GREEN}○{C.ENDC} {neg} neg)")
    print(f"  Secuencia              : {_historial_visual(historial_observaciones)}")
    print(f"  Estado diagnóstico     : {estado_label}")
    print(_linea("─", 55))


def mostrar_resumen_final(estado: Dict[str, Any]):
    """Resumen clínico de la sesión completa."""
    alpha  = estado.get("alpha", 1)
    beta   = estado.get("beta", 1)
    sigma  = estado.get("sigma_post", 1.0)
    umbral = estado.get("umbral_incertidumbre", 0.05)
    c      = estado.get("c", 1.0)
    d_val  = estado.get("d", 1.0)
    n      = len(historial_observaciones)
    pos    = sum(historial_observaciones)
    neg    = n - pos
    media  = alpha / (alpha + beta) if (alpha + beta) > 0 else 0.5
    umbral_bayes = d_val / (c + d_val) if (c + d_val) > 0 else 0.5

    diagnostico = (
        C.RED + "PATOLOGÍA PROBABLE" + C.ENDC if media > umbral_bayes
        else C.GREEN + "AUSENCIA DE PATOLOGÍA PROBABLE" + C.ENDC
    )
    confianza = (
        C.GREEN + "ALTA  (σ < ε)" + C.ENDC if sigma < umbral
        else C.YELLOW + "LIMITADA  (σ ≥ ε, decisión supervisada)" + C.ENDC
    )

    print("\n" + _linea("═", color=C.HEADER))
    print(_titulo("  🏁  RESUMEN DE SESIÓN  ─  DIAGNÓSTICO COMPLETADO"))
    print(_linea("═", color=C.HEADER))
    print(f"  Paciente ID            : {thread_id[:8].upper()}")
    print(f"  Total de pruebas       : {n}  (+ {C.RED}●{C.ENDC}{pos}  / − {C.GREEN}○{C.ENDC}{neg})")
    print(f"  Distribución final     : Beta({alpha}, {beta})")
    print(f"  E[θ] final             : {C.BOLD}{media:.4f}{C.ENDC}")
    print(f"  Incertidumbre σ_post   : {sigma:.4f}  (umbral ε = {umbral})")
    print(f"  Secuencia completa     : {_historial_visual(historial_observaciones)}")
    print(f"  Intervenciones médico  : {num_intervenciones_medico}")
    print(_linea("─", 55))
    print(f"  Diagnóstico sugerido   : {diagnostico}")
    print(f"  Nivel de confianza     : {confianza}")
    print(_linea("═", color=C.HEADER))


# =====================================================================
# PROCESAMIENTO DE FLUJO
# =====================================================================
NODE_LABELS = {
    "inicializar":           ("🔧", C.DIM,    "Sistema inicializado"),
    "observar_prueba":       ("🔬", C.CYAN,   "Observación registrada"),
    "actualizar":            ("📈", C.CYAN,   "Actualización Bayesiana"),
    "calcular_incertidumbre":("📐", C.CYAN,   "Cálculo de riesgo"),
    "decidir_estadistico":   ("🤔", C.BLUE,   "Decisión estadística"),
    "recomendar_tratamiento":("💊", C.GREEN,  "Decisión clínica"),
    "forzar_tratamiento":    ("💊", C.YELLOW, "Decisión clínica (supervisada)"),
    "registrar_advertencia": ("📋", C.DIM,    "Log del sistema"),
}


def procesar_flujo(evento_stream):
    """Procesa y muestra la salida de cada nodo del grafo.

    LangGraph puede emitir valores que no son dicts en ciertos eventos internos
    (p. ej. tuplas de routing cuando un nodo usa Command(goto=...)).
    Se descartan silenciosamente para no romper el flujo.
    """
    for node_name, node_state in evento_stream:
        # Descartar eventos internos de LangGraph que no son estado de nodo
        if not isinstance(node_state, dict):
            continue

        mensajes  = node_state.get("messages", [])
        contenido = mensajes[-1].content if mensajes else ""

        icono, color, etiqueta = NODE_LABELS.get(
            node_name, ("⚙️", C.DIM, node_name)
        )

        # Solo imprimir si hay contenido útil o es un nodo relevante
        if contenido:
            print(f"  {icono} {color}[{etiqueta}]{C.ENDC} {contenido}")
        elif node_name not in ("inicializar", "observar_prueba", "decidir_estadistico"):
            # Nodo ejecutado sin mensaje: traza mínima para debug
            print(f"  {icono} {C.DIM}[{etiqueta}] ejecutado{C.ENDC}")


# =====================================================================
# HELPERS DE FLUJO
# =====================================================================
def _stream_seguro(entrada, cfg):
    """Wrapper para graph.stream con manejo de errores."""
    try:
        for evento in graph.stream(entrada, cfg, stream_mode="updates"):
            procesar_flujo(evento.items())
    except Exception as e:
        print(f"\n  {C.RED}❌ Error durante la ejecución del grafo: {e}{C.ENDC}")
        raise


def _snapshot():
    """Obtiene el estado actual del grafo con manejo de errores."""
    try:
        return graph.get_state(config)
    except Exception as e:
        print(f"\n{C.RED}❌ No se pudo obtener el estado del grafo: {e}{C.ENDC}")
        sys.exit(1)


# =====================================================================
# BUCLE PRINCIPAL
# =====================================================================
def main():
    global num_intervenciones_medico

    mostrar_banner()
    print(f"  🧑‍⚕️  Sesión iniciada  ─  Paciente ID: {C.BOLD}{thread_id[:8].upper()}{C.ENDC}")

    # Inicia el grafo; se detiene solo cuando observar_prueba llama interrupt("OBS").
    print(f"\n  {C.DIM}Inicializando distribución prior Beta(1,1)...{C.ENDC}")
    try:
        _stream_seguro({}, config)
    except Exception as e:
        print(f"{C.RED}❌ Error al inicializar el grafo: {e}{C.ENDC}")
        sys.exit(1)
    print(f"  {C.GREEN}✓{C.ENDC} Prior uniforme listo.\n")

    while True:
        snapshot      = _snapshot()
        estado_actual = snapshot.values

        # ── FIN DEL PROTOCOLO ───────────────────────────────────────────
        if not snapshot.next:
            mostrar_resumen_final(estado_actual)
            break

        if not (snapshot.tasks and snapshot.tasks[0].interrupts):
            break  # No debería ocurrir

        interrupcion = snapshot.tasks[0].interrupts[0].value

        # ── TIPO 1: PEDIR OBSERVACIÓN (interrupt desde observar_prueba) ──
        if str(interrupcion).startswith("OBS"):
            mostrar_dashboard(estado_actual)

            print(f"\n  {C.BOLD}Resultado de la nueva prueba médica:{C.ENDC}")
            print(f"  {C.BOLD}[1]{C.ENDC}  Positivo  {C.RED}●{C.ENDC}  (presencia de patología)")
            print(f"  {C.BOLD}[0]{C.ENDC}  Negativo  {C.GREEN}○{C.ENDC}  (ausencia de patología)")
            print(f"  {C.BOLD}[Q]{C.ENDC}  Salir del sistema")

            while True:
                try:
                    entrada = input("\n  > ").strip().upper()
                except EOFError:
                    print(C.YELLOW + "\n  EOF detectado. Saliendo..." + C.ENDC)
                    sys.exit(0)

                if entrada == "Q":
                    print(C.YELLOW + "\n  Saliendo del sistema. Sesión no completada." + C.ENDC)
                    sys.exit(0)
                if entrada in ("0", "1"):
                    break
                print(f"  {C.RED}❌  Entrada inválida. Ingrese 0, 1 o Q.{C.ENDC}")

            historial_observaciones.append(int(entrada))
            print(C.CYAN + "\n  Ejecutando inferencia estadística..." + C.ENDC)
            # La observación llega al nodo vía Command(resume=x), no como HumanMessage.
            _stream_seguro(Command(resume=int(entrada)), config)

        # ── TIPO 2: CONSULTA AL MÉDICO (interrupt desde consultar_medico) ─
        else:
            num_intervenciones_medico += 1
            mostrar_dashboard(estado_actual)

            print("\n" + _linea("─", 55, C.RED))
            print(_titulo("  🚨  INTERVENCIÓN MÉDICA REQUERIDA", C.RED))
            print(_linea("─", 55, C.RED))
            print(f"  {interrupcion}")
            print(f"  {C.BOLD}[R]{C.ENDC}  Repetir prueba  (muestreo secuencial)")
            print(f"  {C.BOLD}[D]{C.ENDC}  Diagnosticar ya (forzar parada de Wald)")
            print(_linea("─", 55, C.RED))

            while True:
                try:
                    decision = input(f"\n  Tu instrucción {C.BOLD}(R/D){C.ENDC}: ").strip().upper()
                except EOFError:
                    print(C.YELLOW + "\n  EOF detectado. Saliendo..." + C.ENDC)
                    sys.exit(0)
                if decision in ("R", "D"):
                    break
                print(f"  {C.RED}❌  Comando no reconocido. Ingrese R o D.{C.ENDC}")

            print(C.CYAN + "\n  Reanudando razonamiento..." + C.ENDC)
            # Si R → consultar_medico va a observar_prueba → nuevo interrupt("OBS")
            _stream_seguro(Command(resume=decision), config)


# =====================================================================
# PUNTO DE ENTRADA
# =====================================================================
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(
            C.YELLOW + "\n\n  ⚠️  Sistema interrumpido por el usuario. Apagando..." + C.ENDC
        )
        sys.exit(0)
