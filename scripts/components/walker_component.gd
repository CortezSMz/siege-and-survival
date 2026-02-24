class_name WalkerComponent extends Node2D

@export var body : CharacterBody2D
@export var sprite : Node2D
@export var speed : float = 80.0
@export var jump_velocity : float = -300.0

var direction: int

func tick(delta: float) -> void:
	if not body:
		return

	# Gravity
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta


	# Movement
	if body.is_on_floor():
		body.velocity.x = direction * speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, 2.5)

func update_direction(_direction: int) -> void:
	direction = _direction
