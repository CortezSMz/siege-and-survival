class_name ClimbComponent extends Node

signal finished_climbing

@onready var ray_cast_right: RayCast2D = $"../RaycastComponent/RayCastRight"
@onready var ray_cast_left: RayCast2D = $"../RaycastComponent/RayCastLeft"
@onready var ray_cast_bottom_right: RayCast2D = $"../RaycastComponent/RayCastBottomRight"
@onready var ray_cast_bottom_left: RayCast2D = $"../RaycastComponent/RayCastBottomLeft"

@export var body : CharacterBody2D
@export var climb_speed : float = -60.0
var is_active = false
var climbing_right = false
var climbing_left = false

func climb():
	is_active = true
	body.modulate = Color.GREEN

func _physics_process(delta) -> void:
	if not is_active:
		return

	if not body.is_on_floor() and not (climbing_left or climbing_right):
		body.velocity += body.get_gravity() * delta

	# CLIMBING RIGHT
	if ray_cast_right.is_colliding():
		climbing_right = true
		body.velocity.y = climb_speed
		body.velocity.x = 0
	if not ray_cast_right.is_colliding() and climbing_right:
		if not ray_cast_bottom_right.is_colliding():
			finish_climb()

	# CLIMBING LEFT
	if ray_cast_left.is_colliding():
		climbing_left = true
		body.velocity.y = climb_speed
		body.velocity.x = 0
	if not ray_cast_left.is_colliding() and climbing_left:
		if not ray_cast_bottom_left.is_colliding():
			finish_climb()



func finish_climb() -> void:
	finished_climbing.emit()
	is_active = false
	body.velocity.y = 0
	
	# Empurrãozinho para frente para ele não cair no buraco de novo
	if climbing_right:
		body.position.x += (body.direction * 5)
	elif climbing_left:
		body.position.x -= -(body.direction * 5)
		
	climbing_right = false
	climbing_left = false

	body.modulate = Color.WHITE
