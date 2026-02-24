class_name RaycastComponent extends Node2D

@export var rc_right : RayCast2D
@export var rc_left : RayCast2D
@export var rc_bottom_right : RayCast2D
@export var rc_bottom_left : RayCast2D
@export var rc_top_right : RayCast2D
@export var rc_top_left : RayCast2D
@export var rc_top : RayCast2D

func get_direction(old_direction) -> int:
	var direction = old_direction

	# Left - right
	if rc_right.is_colliding():
		direction = -1
	if  rc_left.is_colliding():
		direction = 1

	return direction
