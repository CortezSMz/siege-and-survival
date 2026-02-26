class_name FloaterComponent extends Node

signal finished_floating

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var fall_speed_limit : float = 40.0

var is_deployed = false


func setup():
	body.modulate = Color.CYAN
	is_deployed = false


func execute(delta: float) -> void:
	if not body:
		return

	if not is_deployed:
		walker_component.execute(delta)
		
		if not body.is_on_floor() and body.velocity.y > 300:
			is_deployed = true
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, 2.5)
		body.velocity.y = fall_speed_limit
		

		if body.is_on_floor():
			_finish_floater()


func _finish_floater():
	is_deployed = false
	finished_floating.emit()


func stop_action():
	is_deployed = false
	body.modulate = Color.WHITE
