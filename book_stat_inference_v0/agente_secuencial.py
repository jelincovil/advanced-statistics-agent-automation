from dataclasses import dataclass, field
import json
import math
import numpy as np


@dataclass
class Estado:
    alpha: float = 0.05
    counts: list = field(default_factory=lambda: [0, 0])
    totals: list = field(default_factory=lambda: [0.0, 0.0])
    decision: int | None = None

    def observar(self, action, reward):
        if action not in (0, 1) or not 0 <= reward <= 1:
            raise ValueError('Acción o recompensa fuera del experimento')
        if not 0 < self.alpha < 1:
            raise ValueError('alpha debe estar entre cero y uno')
        self.counts[action] += 1
        self.totals[action] += reward

    def intervalos(self):
        intervals = []
        for count, total in zip(self.counts, self.totals):
            if count == 0:
                intervals.append((0.0, 1.0))
            else:
                radius = math.sqrt(math.log(4 * count * (count + 1) / self.alpha) / (2 * count))
                mean = total / count
                intervals.append((max(0.0, mean - radius), min(1.0, mean + radius)))
        return intervals

    def decidir(self):
        intervals = self.intervalos()
        if intervals[1][0] > intervals[0][1]:
            self.decision = 1
        elif intervals[0][0] > intervals[1][1]:
            self.decision = 0
        return self.decision


def ejecutar(seed=20261029, probabilities=(0.3, 0.7), budget=2000, alpha=0.05):
    generator = np.random.default_rng(seed)
    state = Estado(alpha=alpha)
    for round_number in range(budget):
        action = round_number % 2
        reward = float(generator.random() < probabilities[action])
        state.observar(action, reward)
        if state.decidir() is not None:
            break
    return {'seed': seed, 'probabilities': probabilities, 'budget': budget, 'alpha': alpha,
            'counts': state.counts, 'intervals': state.intervalos(), 'decision': state.decision,
            'status': 'seleccion_certificada' if state.decision is not None else 'abstencion'}


def verificar():
    for index in range(1, 100):
        assert math.isclose(1 / (index * (index + 1)), 1 / index - 1 / (index + 1))
    state = Estado()
    assert state.decidir() is None
    result = ejecutar()
    assert result['decision'] == 1
    assert sum(result['counts']) <= result['budget']
    assert result['intervals'][1][0] > result['intervals'][0][1]
    equal_result = ejecutar(probabilities=(0.5, 0.5), budget=2)
    assert equal_result['decision'] is None
    return result


if __name__ == '__main__':
    print(json.dumps(verificar(), ensure_ascii=False, indent=2))
