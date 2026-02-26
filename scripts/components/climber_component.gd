class_name ClimberComponent extends Node

signal finished_climbing

@onready var ray_cast_top: RayCast2D = %RayCastTop
@onready var ray_cast_right: RayCast2D = %RayCastRight
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_feet_right: RayCast2D = %RayCastFeetRight
@onready var ray_cast_feet_left: RayCast2D = %RayCastFeetLeft

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var climber_speed : float = -60.0

var is_climbing = false


func setup():
	body.modulate = Color.GREEN
	is_climbing = false


func execute(delta: float) -> void:
	if not body:
		return

	var dir = walker_component.direction
	
	if not is_climbing:
		if _is_wall_climbable(dir):
			is_climbing = true
			body.velocity.y = climber_speed

			return
		
		walker_component.execute(delta)
	else:
		body.velocity.y = climber_speed
		
		if ray_cast_top.is_colliding():
			_finish_climb()
		
		if dir > 0:
			if not ray_cast_right.is_colliding() and not ray_cast_feet_right.is_colliding():
				_finish_climb()
		elif dir < 0:
			if not ray_cast_left.is_colliding() and not ray_cast_feet_left.is_colliding():
				_finish_climb()


func _is_wall_climbable(dir: int) -> bool:
	var ray = ray_cast_right if dir > 0 else ray_cast_left
	if ray.is_colliding():
		var collider = ray.get_collider()
		return collider is TileMapLayer
	return false


func _finish_climb() -> void:
	is_climbing = false
	body.velocity = Vector2.ZERO
	
	body.global_position.y = snapped(body.global_position.y, 8) - 1

	var target_x = body.global_position.x + (walker_component.direction * 8)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(body, "global_position:x", target_x, 0.15)
	
	tween.finished.connect(func():
		body.velocity.x = walker_component.direction * walker_component.speed
		finished_climbing.emit()
	)


func stop_action() -> void:
	is_climbing = false
	body.modulate = Color.WHITE
