import math
import numpy as np


def soporte_cubierto(target, behavior):
    return all(target_probability == 0 or behavior_probability > 0
               for target_probability, behavior_probability in zip(target, behavior))


def verificar():
    assert soporte_cubierto((1., 0.), (.5, .5))
    assert not soporte_cubierto((.5, .5), (1., 0.))
    candidate = np.array([10., -10.])
    behavior = np.array([.5, .5])
    direct = behavior @ candidate
    dr = direct - candidate
    assert math.isclose(behavior @ dr, 0.)
    assert math.isclose(behavior @ dr**2, 100.)
    causal_value = 0.5
    is_expectation = 0.
    for latent in (0, 1):
        action_probability = .8 if latent else .2
        for action in (0, 1):
            joint_probability = .5 * (action_probability if action else 1-action_probability)
            is_expectation += joint_probability * latent
    assert math.isclose(is_expectation, causal_value)
    covariance = np.array([[4., 1.2], [1.2, 9.]])
    target = np.array([.6, .4])
    assert math.isclose(target @ covariance @ target, 3.456)
    assert math.isclose((target @ covariance @ target) / 50, .06912)
    discount = .9
    rewards = np.array([[1., .5], [0., -.5]])
    next_states = np.array([[1, 0], [1, 0]])
    optimal = np.array([5., 4.])
    assert np.allclose(np.max(rewards+discount*optimal[next_states],axis=1), optimal)
    for initial in (np.zeros(2), np.array([2., -1.])):
        residual = np.max(np.abs(np.max(rewards+discount*initial[next_states],axis=1)-initial))
        assert np.max(np.abs(initial-optimal)) <= residual/(1-discount)+1e-12
    assert math.log(1 / 1e-6) > math.log(1 / 1e-3)
    assert math.isclose(sum(1/(index*(index+1)) for index in range(1,1001)), 1-1/1001)
    print('OK: overlap, contraejemplo DR, cancelación de confusión, escala delta, Bellman y gasto de alfa.')


if __name__ == '__main__':
    verificar()
