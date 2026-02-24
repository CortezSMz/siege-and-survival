class_name ClimbComponent extends Node

signal finished_climbing

@onready var ray_cast_top: RayCast2D = %RayCastTop
@onready var ray_cast_right: RayCast2D = %RayCastRight
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_bottom_right: RayCast2D = %RayCastBottomRight
@onready var ray_cast_bottom_left: RayCast2D = %RayCastBottomLeft

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var climb_speed : float = -60.0

var is_active = false
var is_climbing = false

func start_action():
	body.modulate = Color.GREEN
	is_active = true

func _physics_process(delta) -> void:
	if not is_active:
		return
	
	# Keep movement and gravity while not is_climbing
	if not is_climbing:
		walker_component.tick(delta)

	# CLIMBING RIGHT
	if ray_cast_right.is_colliding() and body.direction > 0:
		is_climbing = true
		body.velocity.y = climb_speed
		body.velocity.x = 0
	if not ray_cast_right.is_colliding() and is_climbing and body.direction > 0:
		if not ray_cast_bottom_right.is_colliding():
			finish_climb()

	# CLIMBING LEFT
	if ray_cast_left.is_colliding() and body.direction < 0:
		is_climbing = true
		body.velocity.y = climb_speed
		body.velocity.x = 0
	if not ray_cast_left.is_colliding() and is_climbing and body.direction < 0:
		if not ray_cast_bottom_left.is_colliding():
			finish_climb()
	
	# HEAD 
	if is_climbing and ray_cast_top.is_colliding():
		finish_climb()


func finish_climb() -> void:
	# Keep walking without gravity in order to not fall again
	body.velocity.y = 0
	body.velocity.x = body.direction * walker_component.speed
	await get_tree().create_timer(0.2).timeout

	body.modulate = Color.WHITE

	is_active = false
	is_climbing = false
	finished_climbing.emit()

func stop() -> void:
	is_active = false
	is_climbing = false
	body.modulate = Color.WHITE
	finished_climbing.emit()
