extends Node

@warning_ignore("unused_signal")
signal level_ready(level: BaseLevel)
@warning_ignore("unused_signal")
signal level_ended()
@warning_ignore("unused_signal")
signal player_died()
@warning_ignore("unused_signal")
signal player_near_end()
@warning_ignore("unused_signal")
signal timer_restarted()
@warning_ignore("unused_signal")
signal timer_started()
@warning_ignore("unused_signal")
signal timer_stopped()
@warning_ignore("unused_signal")
signal score_emitted(score:float)

@warning_ignore("unused_signal")
signal squid_charge_started()
@warning_ignore("unused_signal")
signal squid_charge_done(thrust_factor: float)

@warning_ignore("unused_signal")
signal player_energy_changed(new_energy:int)
@warning_ignore("unused_signal")
signal player_max_energy_changed(new_max_energy:int)
@warning_ignore("unused_signal")
signal debug_max_energy()
@warning_ignore("unused_signal")
signal entered_music_area(idx:int)


@warning_ignore("unused_signal")
signal trigger_shark
