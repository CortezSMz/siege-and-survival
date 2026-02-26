class_name BuilderSidesComponent extends Node

signal finished_building

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var brick_data : BuilderBrickData 
@export var ray_cast_down_right : RayCast2D
@export var ray_cast_down_left : RayCast2D

@onready var raycast_component: RaycastComponent = $"../RaycastComponent"

var tile_map : TileMapLayer
var bricks_left : int = 0
var build_timer : float = 0.0
var is_building : bool = false

# Natural movement control
var is_walking_to_pos : bool = false
var start_x : float = 0.0
var initial_direction : int = 0

func setup():
	body.modulate = Color.ORANGE
	bricks_left = brick_data.max_bricks
	is_building = false
	is_walking_to_pos = false
	build_timer = 0.0
	tile_map = get_tree().get_first_node_in_group("level_tilemap")

func execute(delta: float):
	if not body or not tile_map: return

	# Building and natural movement - walker_component assumes movement for a while
	if is_walking_to_pos:
		walker_component.execute(delta)

		# Distance travaled since last platform
		var distance_traveled = abs(body.global_position.x - start_x)

		# Stop if it hits an obstacle and changes direction
		if walker_component.direction != initial_direction:
			_finish_building()
			return

		# If it walked 16px,
		if distance_traveled >= 15.5:
			_finalize_step()
		return

	# Searching for edge phase
	if not is_building:
		walker_component.execute(delta)
		
		if _is_at_edge():
			is_building = true
			initial_direction = walker_component.direction
			body.velocity = Vector2.ZERO
			
	# Building phase
	else:
		build_timer += delta
		if build_timer >= brick_data.build_time:
			build_timer = 0.0
			_try_place_platform()


func _is_at_edge() -> bool:
	var rc_down = ray_cast_down_right if walker_component.direction > 0 else ray_cast_down_left
	if raycast_component.get_direction(walker_component.direction) != walker_component.direction:
		return false
	return not rc_down.is_colliding() and body.is_on_floor()


func _try_place_platform():
	# Calculate platforms position - 8px grid
	var p1 = body.global_position + Vector2(initial_direction * 8, 4)
	var p2 = body.global_position + Vector2(initial_direction * 16, 4)

	var m1 = tile_map.local_to_map(tile_map.to_local(p1))
	var m2 = tile_map.local_to_map(tile_map.to_local(p2))

	# Checks if any positions are available
	var first_pos = tile_map.get_cell_source_id(m1) != -1
	var second_pos = tile_map.get_cell_source_id(m2) != -1
	var free_positions_qty = [first_pos, second_pos].filter(func(e): return not e).size()

	# Finish if both positions are ocupied
	if first_pos and second_pos:
		return _finish_building()

	# Finish if there's not enought bricks left
	if bricks_left < free_positions_qty:
		return _finish_building()



	# Place platform
	if (not first_pos): tile_map.set_cell(m1, brick_data.source_id, brick_data.atlas_coords)
	if (not second_pos): tile_map.set_cell(m2, brick_data.source_id, brick_data.atlas_coords)
	
	bricks_left -= free_positions_qty

	# Go back to natural movement
	start_x = body.global_position.x
	is_walking_to_pos = true


func _finalize_step():
	is_walking_to_pos = false
	
	# 16px SNAPPING
	body.global_position.x = start_x + (initial_direction * 16)
	body.velocity.x = 0
	
	# If no bricks left or not ad edge, finish_building
	if bricks_left <= 0 or not _is_at_edge():
		walker_component.update_direction(-initial_direction)
		_finish_building()


func _finish_building():
	is_building = false
	is_walking_to_pos = false
	finished_building.emit()


func stop_action():
	is_building = false
	is_walking_to_pos = false
	body.modulate = Color.WHITE
