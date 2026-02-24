class_name ParachuteComponent extends Node

signal finished_parachuting

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var raycast_component : RaycastComponent
@export var fall_speed_limit : float = 40.0

var is_active = false
var is_deployed = false

func start_action():
	body.modulate = Color.CYAN
	is_active = true

func _physics_process(delta) -> void:
	if not is_active and not is_deployed:
		return
	
	if is_active and not is_deployed:
		body.direction = raycast_component.get_direction(body.direction)
		walker_component.update_direction(body.direction)
		walker_component.tick(delta)
		
		if not body.is_on_floor() and body.velocity.y > 0:
			body.velocity.x = move_toward(body.velocity.x, 0, 2.5)
			is_deployed = true
			is_active = false

	if is_deployed:
		body.velocity.x = move_toward(body.velocity.x, 0, 2.5)
		
		if body.velocity.y > fall_speed_limit:
			body.velocity.y = fall_speed_limit
		
		if body.is_on_floor():
			finish_parachute()

func finish_parachute() -> void:
	body.modulate = Color.WHITE
	is_deployed = false
	is_active = false
	finished_parachuting.emit()

func stop() -> void:
	is_active = false
	is_deployed = false
	body.modulate = Color.WHITE
	finished_parachuting.emit()
