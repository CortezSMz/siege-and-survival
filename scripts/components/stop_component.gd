class_name StopComponent extends Node

signal finished_blocking

@export var body : CharacterBody2D

var is_active = false

func start_action():
	is_active = true
	body.modulate = Color.RED
	
	body.set_collision_layer_value(1, true)

func _physics_process(delta) -> void:
	if not is_active:
		return
	
	body.velocity.x = 0
	#if not body.is_on_floor():
		#body.velocity += body.get_gravity() * delta


func stop():
	body.set_collision_layer_value(1, false)
	body.modulate = Color.WHITE
	is_active = false
	finished_blocking.emit()
