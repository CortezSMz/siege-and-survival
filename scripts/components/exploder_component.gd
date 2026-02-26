class_name ExploderComponent extends Node

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var exploder_data : ExploderData
@export var head_label : Label

var tile_map : TileMapLayer
var fuse_timer : float = 0.0
var is_active : bool = false

func setup():
	is_active = true
	fuse_timer = exploder_data.fuse_time
	tile_map = get_tree().get_first_node_in_group("level_tilemap")
	if head_label: head_label.visible = true

func execute(delta: float):
	if not is_active: return

	else:
		walker_component.execute(delta)

	# Head timer
	fuse_timer -= delta
	if head_label:
		var count = ceil(fuse_timer)
		head_label.text = str(count) if count > 0 else "OH NO!"

	# Sprite blink	
	var flash_speed = 0.4 if fuse_timer > 2.0 else 0.1
	body.modulate = Color.RED if fmod(fuse_timer, flash_speed * 2) > flash_speed else Color.WHITE

	if fuse_timer <= 0:
		_explode()


func _explode():
	is_active = false
	if head_label: head_label.visible = false
	
	if tile_map:
		_destroy_tiles_in_radius()
	
	body.queue_free()


func _destroy_tiles_in_radius():
	if not tile_map: 
		return

	var center_global = body.global_position + Vector2(0, -16)
	var local_pos = tile_map.to_local(center_global)
	var center_cell = tile_map.local_to_map(local_pos)
	
	var r = int(exploder_data.explosion_radius / 8.0) + 1

	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			var target_cell = center_cell + Vector2i(x, y)

			tile_map.set_cell(target_cell, -1)


func stop_action():
	is_active = false
	if head_label: head_label.visible = false
	body.modulate = Color.WHITE
