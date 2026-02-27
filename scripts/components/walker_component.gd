class_name WalkerComponent extends Node2D

@export var body : CharacterBody2D
@export var speed : float = 80.0

@onready var raycast_component: RaycastComponent = %RaycastComponent

var direction: int = 1
var is_stepping_up: bool = false


func setup():
	body.modulate = Color.WHITE


func execute(delta: float) -> void:
	if not body or not raycast_component:
		return
	
	if is_stepping_up:
		return

	# Update direction
	var new_dir = raycast_component.get_direction(direction)
	if new_dir != direction: 
		update_direction(new_dir)

	# Check if body is stuck on a block (4px) gap
	if raycast_component.is_body_stuck(body.velocity.x):
		apply_small_push()
		return

	# Step up 8px blocks
	if raycast_component.is_step_up_needed(direction):
		apply_step_up()
		return

	# Gravity
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta

	# Horizontal movement
	if body.is_on_floor():
		body.velocity.x = direction * speed
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, 2.5)


func update_direction(new_direction: int) -> void:
	direction = new_direction


func apply_small_push() -> void:
	body.position.x += direction * 1


func apply_step_up() -> void:
	if is_stepping_up: return
	
	is_stepping_up = true
	
	body.velocity = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	var target_pos = body.global_position + Vector2(direction * (GridUtils.TILE_SIZE / 2), -GridUtils.TILE_SIZE)
	
	tween.tween_property(body, "global_position", target_pos, 0.1)
	
	tween.finished.connect(func():
		is_stepping_up = false
	)


func stop_action() -> void:
	is_stepping_up = false
