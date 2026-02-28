class_name BlockerComponent extends Node

signal finished_blocking

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent


func setup():
	body.modulate = Color.RED
	
	body.velocity.x = 0

	body.set_collision_layer_value(3, true)


func execute(delta: float):
	if not body:
		return

	body.velocity.x = 0
	
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta


func stop_action():
	body.modulate = Color.WHITE

	body.set_collision_layer_value(3, false)

	finished_blocking.emit()
