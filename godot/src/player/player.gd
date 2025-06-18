class_name Player extends RigidBody2D

@export_category("thrust")
@export var base_thrust_timeout := .8
@export var thrust := 400.0
@export var back_thrust_factor := .2
@export var strafe_thrust_factor := .25
@export var full_thrust_bonus := 1.2
@export var wall_thrust_factor := 1.5
@export var thrust_charge_speed :=1.0
@export var min_thrust_timeout := .4
@export var perfect_thrust_interval = Vector2(0.8,.9)
@export var super_thrust := 800
@export_category("other movement")
@export var rotation_speed :=2.5
@export var friction := .7
@export_category("energy")
@export var max_energy := 100


var energy := 0:
	set(v):
		energy = v
		energy = clamp(energy, 0, max_energy)
		Events.player_energy_changed.emit(energy)

var in_animation:=false
var can_thrust:=true
var thrust_factor := 0.0
var last_thrust_direction:=Vector2.RIGHT
var currents:int:
	set(_val):
		var has_current = currents > 0
		currents=_val
		if has_current and currents ==0:
			Logger.debug("leaving current %d" % currents)
			var vol=loop_current_sfx.volume_db
			var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(loop_current_sfx,"volume_db",-40,.3)
			await tween.finished
			loop_current_sfx.stop()
			loop_current_sfx.volume_db = vol
		elif not has_current and currents > 0:
			#enter_current_sfx.play()
			#await enter_current_sfx.finished
			
			var vol=loop_current_sfx.volume_db
			loop_current_sfx.volume_db = -40
			loop_current_sfx.play()
			var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(loop_current_sfx,"volume_db",vol,.3)
			await tween.finished
			
			Logger.debug("entering current %d" % currents)
			
			if currents >0:
				loop_current_sfx.play()
		

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back_rc: RayCast2D = $BackRC

@onready var charge_sfx: AudioStreamPlayer2D = $sfx/charge_sfx
@onready var tap_sfx: AudioStreamPlayer2D = $sfx/tap_sfx
@onready var thrust_sfx: AudioStreamPlayer2D = $sfx/thrust_sfx
@onready var enter_current_sfx: AudioStreamPlayer2D = $sfx/enter_current_sfx
@onready var loop_current_sfx: AudioStreamPlayer2D = $sfx/loop_current_sfx
@onready var hurt_sfx: AudioStreamPlayer2D = $sfx/hurt_sfx
@onready var krill_sfx: AudioStreamPlayer2D = $sfx/krill_sfx
@onready var ruffle_sfx: AudioStreamPlayer2D = $sfx/ruffle_sfx
@onready var bubbles: AnimatedSprite2D = $Bubbles

func _ready():
	animation_player.play("idle")
	Events.player_max_energy_changed.emit(max_energy)
	bubbles.animation_finished.connect(func():bubbles.visible = false)
	energy=100
	
func _physics_process(delta: float) -> void:
	if in_animation :
		return
	
	var rotate_input:float = Input.get_axis("rotate_left","rotate_right")
	if rotate_input:
		rotation += rotate_input * rotation_speed * delta

	if can_thrust:
		if Input.is_action_pressed("move_forward"):
			charge_thrust(delta)
		elif Input.is_action_just_released("move_forward"):
			last_thrust_direction = Vector2.RIGHT
			do_thrust()
		if Input.is_action_just_pressed("move_back"):
			last_thrust_direction = Vector2.LEFT
			thrust_factor = back_thrust_factor
			do_thrust(PI)
		elif Input.is_action_just_pressed("move_left"):
			last_thrust_direction = Vector2.UP
			thrust_factor=strafe_thrust_factor
			do_thrust(-PI/2)
		elif Input.is_action_just_pressed("move_right"):
			last_thrust_direction = Vector2.DOWN
			thrust_factor=strafe_thrust_factor
			do_thrust(PI/2)
		elif Input.is_action_just_released("boost"):
			last_thrust_direction = Vector2.RIGHT
			do_super_thrust()
func charge_thrust(delta:float):
	if thrust_factor == 0:
		thrust_factor = .2	
		animation_player.play("charge")
		Events.squid_charge_started.emit()
		Logger.info("start charge %d" %  Time.get_ticks_msec())
		charge_sfx.play()
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		last_thrust_direction = Vector2.RIGHT
		do_thrust()
	
func is_perfect_thrust()->bool:
	var perfect :bool = thrust_factor >= perfect_thrust_interval.x and thrust_factor <= perfect_thrust_interval.y
	Logger.info("thrust factor %.2f window %s" % [thrust_factor, perfect_thrust_interval])
	if perfect:
		Logger.info("perfect thrust")
	return perfect

func do_thrust(rotation_delta:float = 0):
	var thrust_direction=Vector2.RIGHT.rotated(rotation+rotation_delta)
	Logger.debug("thrust %d" % Time.get_ticks_msec())
	if thrust_factor > .5:
		thrust_sfx.play()
	else:
		tap_sfx.play()
	
	var intensity:float = thrust * \
		(full_thrust_bonus if is_perfect_thrust() else thrust_factor) *\
		(wall_thrust_factor if back_rc.is_colliding() else 1)
	Logger.info("thrust factor %2.f intensity %.2f" % [thrust_factor, intensity])
	apply_impulse(thrust_direction * intensity,Vector2.ZERO)
	Events.squid_charge_done.emit(thrust_factor)
	if back_rc.is_colliding():
		bubbles.play("default")
		bubbles.visible = true
	#do_noise()
	can_thrust=false
	match last_thrust_direction:
		Vector2.LEFT:
			Logger.debug("thrust back")
			animation_player.play("back")
		Vector2.UP:
			Logger.debug("strafe left")
			animation_player.play("strafe_left")
		Vector2.DOWN:
			Logger.debug("strafe right")
			animation_player.play("strafe_right")
		_:
			Logger.debug("thrust forward")
			animation_player.play("thrust")

			
	$ThrustTimer.wait_time = max(min_thrust_timeout, base_thrust_timeout*thrust_factor )
	Logger.info("wait time %.2f" % $ThrustTimer.wait_time )
	thrust_factor=0
	$ThrustTimer.start()
	Logger.debug("thrust NOT available %d" % Time.get_ticks_msec())
	
		
func do_super_thrust():
	if not can_boost():
		return
	Events.player_energy_changed.emit(energy)
	in_animation = true
	var thrust_direction=Vector2.RIGHT
	animation_player.play("super_thrust")
	var intensity:float = super_thrust *\
		(wall_thrust_factor if back_rc.is_colliding() else 1)
	await get_tree().create_timer(.4).timeout
	var tween:=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"energy",0,.3)
	apply_impulse(thrust_direction * intensity,Vector2.ZERO)
	await get_tree().create_timer(.3).timeout
	in_animation=false
	await animation_player.animation_finished
	_on_thrust_timer_timeout()
	
func _on_thrust_timer_timeout() -> void:
	can_thrust=true
	Logger.debug("thrust available %d" % Time.get_ticks_msec())
	match last_thrust_direction:		
		Vector2.RIGHT:
			if not Input.is_action_pressed("move_forward"):
				animation_player.play("thrust_to_idle")
				await animation_player.animation_finished
				animation_player.play("idle")
		_:
			animation_player.play("idle")

	


#func kill():
	#Logger.info("hurt")
	#visible=false
	#hurt_sfx.play()
	#await get_tree().create_timer(1).timeout
	#Globals.do_lose()

func on_ruffle():
	if not ruffle_sfx.playing:
		ruffle_sfx.play()
		
func collect(node:EnergyNode):
	
	energy = min(node.energy+energy, max_energy)
	Events.player_energy_changed.emit(energy)
	Logger.info("Player collected energy. Energy = %d" % energy)
	
func can_boost()->bool:
	return energy == max_energy
	
	
func lose_camera():
	var node:Node2D = get_node("RemoteTransform2D")
	if node:
		node.queue_free()
	
