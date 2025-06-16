extends Node

signal level_ready(level: BaseLevel)
signal level_ended()
signal player_died()

signal timer_restarted()
signal timer_started()
signal timer_stopped()
signal score_emitted(score:float)

signal squid_charge_started()
signal squid_charge_done(thrust_factor: float)

signal player_energy_changed(new_energy:int)
