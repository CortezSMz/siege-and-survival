class_name RaycastComponent extends Node2D

@export var rc_top: RayCast2D
@export var rc_head_right: RayCast2D
@export var rc_head_left: RayCast2D
@export var rc_torso_right: RayCast2D
@export var rc_torso_left: RayCast2D
@export var rc_right: RayCast2D
@export var rc_left: RayCast2D
@export var rc_knee_right: RayCast2D
@export var rc_knee_left: RayCast2D
@export var rc_feet_right: RayCast2D
@export var rc_feet_left: RayCast2D
@export var rc_down_right: RayCast2D
@export var rc_down_left: RayCast2D


func get_direction(old_direction) -> int:
	var direction = old_direction

	if rc_right.is_colliding() or rc_torso_right.is_colliding() or rc_head_right.is_colliding():
		direction = -1
	elif rc_left.is_colliding() or rc_torso_left.is_colliding() or rc_head_left.is_colliding():
		direction = 1

	return direction


func is_body_stuck(x_velocity: float) -> bool:
	return 	(x_velocity == 0
		and	(rc_feet_right.is_colliding() and rc_down_right.is_colliding() and not rc_knee_right.is_colliding())
		and	(rc_feet_left.is_colliding() and rc_down_left.is_colliding() and not rc_knee_left.is_colliding()))


func is_step_up_needed(direction: int) -> bool:
	if direction > 0:
		return (rc_knee_right.is_colliding() and not rc_right.is_colliding())
	elif direction < 0:
		return rc_knee_left.is_colliding() and not rc_left.is_colliding()

	return false
