class_name BuilderSidesComponent extends Node

signal finished_building

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var ray_cast_down_right : RayCast2D
@export var ray_cast_down_left : RayCast2D
@export var platform_data : BuilderPlatformData

@onready var raycast_component: RaycastComponent = %RaycastComponent

var tile_map : TileMapLayer
var platforms_left : int = 0
var build_timer : float = 0.0
var is_building : bool = false

# Natural movement control
var is_walking_to_pos : bool = false
var start_x : float = 0.0
var initial_direction : int = 0


func setup():
	body.modulate = Color.ORANGE
	platforms_left = int(platform_data.max_platforms * (platform_data.platform_size))
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
		if distance_traveled >= ((platform_data.platform_size * GridUtils.TILE_SIZE) - 0.5):
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
		if build_timer >= platform_data.build_time:
			build_timer = 0.0
			_try_place_platform()


func _is_at_edge() -> bool:
	var rc_down = ray_cast_down_right if walker_component.direction > 0 else ray_cast_down_left
	if raycast_component.get_direction(walker_component.direction) != walker_component.direction:
		return false
	return not rc_down.is_colliding() and body.is_on_floor()


func _try_place_platform():
	var empty_slots = GridUtils.get_step_offsets((platform_data.platform_size * GridUtils.TILE_SIZE)).map(
		func(offset): 
			var global_p = body.global_position + Vector2(initial_direction * offset, 4)
			return tile_map.local_to_map(tile_map.to_local(global_p))
	).filter(
		func(map_pos): return tile_map.get_cell_source_id(map_pos) == -1
	)

	# Finish if there's no empty_slots to place a platform
	if empty_slots.is_empty():
		return _finish_building()

	# Finish if there's not enough platforms
	if platforms_left < empty_slots.size():
		return _finish_building()

	# Place platforms
	for map_pos in empty_slots:
		tile_map.set_cell(map_pos, platform_data.source_id, platform_data.atlas_coords)
		platforms_left -= 1

	start_x = body.global_position.x
	is_walking_to_pos = true


func _finalize_step():
	is_walking_to_pos = false
	
	# Snap to the end of the platform
	body.global_position.x = start_x + (initial_direction * (platform_data.platform_size * GridUtils.TILE_SIZE))
	body.velocity.x = 0
	
	# If no platforms left or not at an edge, finish_building
	if platforms_left <= 0 or not _is_at_edge():
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
