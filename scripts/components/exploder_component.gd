class_name ExploderComponent extends Node

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var exploder_data : ExploderData
@export var head_label : Label

var tile_maps : Array = []
var fuse_timer : float = 0.0
var is_active : bool = false
var was_stationary_on_start : bool = false 


func setup():
	is_active = true
	fuse_timer = exploder_data.fuse_time
	
	tile_maps = get_tree().get_nodes_in_group("destructible_tilemap")
	
	was_stationary_on_start = is_zero_approx(body.velocity.x)
	
	if head_label: 
		head_label.visible = true


func execute(delta: float):
	if not is_active: return

	if was_stationary_on_start:
		body.velocity.x = 0

		if not body.is_on_floor():
			body.velocity += body.get_gravity() * delta
	else:
		walker_component.execute(delta)

	# head_label timer
	fuse_timer -= delta
	if head_label:
		var count = ceil(fuse_timer * 2.0) / 2.0
		head_label.text = str(ceil(count)) if count > .5 else "OH NO!"

	var flash_speed = 0.4 if fuse_timer > 2.0 else 0.1
	body.modulate = Color.RED if fmod(fuse_timer, flash_speed * 2.0) > flash_speed else Color.WHITE

	if fuse_timer <= 0:
		_explode()


func _explode():
	is_active = false
	if head_label: head_label.visible = false
	
	_destroy_tiles_in_radius()
	body.queue_free()


func _destroy_tiles_in_radius():
	var center_global = body.global_position + Vector2(0, -16)
	var r = exploder_data.explosion_radius
	var r_squared = (r * r)

	for tm in tile_maps:
		if not tm is TileMapLayer: continue
		
		var local_pos = tm.to_local(center_global)
		var center_cell = tm.local_to_map(local_pos)
		
		for x in range(-r, r + 1):
			for y in range(-r, r + 1):
				# If the sum of the squares of the distances is less than or equal to the squared radius, it is inside the circle
				if (x * x) + (y * y) <= r_squared:
					var target_cell = center_cell + Vector2i(x, y)
					tm.set_cell(target_cell, -1)


func stop_action():
	is_active = false
	if head_label: head_label.visible = false
	body.modulate = Color.WHITE
