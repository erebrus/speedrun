class_name Tentacle extends Node2D

@export var flip: bool

@export var player: Player:
	set(value):
		player = value
		if is_node_ready() and player != null:
			sections.back().next = player
			player.hidden.connect(hide)


var sections: Array[TentacleSection]
var built: bool

@onready var line: Line2D = $Line2D
@onready var tentacle_end: Sprite2D = %TentacleEnd

func _ready() -> void:
	
	if flip:
		tentacle_end.flip_v = true
	
	for child in $Sections.get_children():
		sections.append(child as TentacleSection)
	if player != null:
		sections.back().next = player
	

func build() -> void:
	for i in sections.size() - 1:
		sections[i].next = sections[i+1]
	
	built = true
	

func _physics_process(_delta: float) -> void:
	if not built:
		return
	
	var curve = Curve2D.new()
	curve.add_point(sections.front().position)
	for i in range(1, sections.size() - 1):
		var previous = sections[i-1]
		var next = sections[i+1]
		var direction = previous.position.direction_to(next.position)
		var point_in = - direction * 2.5 
		var point_out =  direction * 2.5
		
		curve.add_point(sections[i].position, point_in, point_out)
	
	curve.add_point(sections.back().position)
	curve.bake_interval = 1
	
	line.points = curve.get_baked_points()
	
