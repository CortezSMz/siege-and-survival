class_name BuilderDiagUpComponent extends Node

signal finished_building

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var platform_data : BuilderPlatformData

@onready var raycast_component: RaycastComponent = %RaycastComponent

var tile_map : TileMapLayer
var platforms_left : int = 0
var build_timer : float = 0.0
var is_building : bool = false

# Natural movement control
var is_walking_to_pos : bool = false
var start_x : float = 0.0
var start_y : float = 0.0
var initial_direction : int = 0

func setup():
	body.modulate = Color.YELLOW 
	
	platforms_left = int(platform_data.max_platforms * platform_data.platform_size)
	is_building = true 
	initial_direction = walker_component.direction
	
	is_walking_to_pos = false
	build_timer = 0.0
	tile_map = get_tree().get_first_node_in_group("construction_tilemap")

var step = 1
func execute(delta: float):
	if not body or not tile_map: return

	# Natural movement
	if is_walking_to_pos:
		if walker_component.direction != initial_direction:
			_finish_building()
			return

		walker_component.execute(delta)

		var distance_traveled = abs(body.global_position.x - start_x)
		
		if distance_traveled >= ((platform_data.platform_size * GridUtils.TILE_SIZE) - 0.5):
			_finalize_step()
			step+=1
		return

	# Searching for edge phase
	if not is_building:
		walker_component.execute(delta)
		
		if body.is_on_floor():
			is_building = true
			initial_direction = walker_component.direction
			body.velocity = Vector2.ZERO
	else:
		# Building cicle
		build_timer += delta
		if build_timer >= platform_data.build_time:
			build_timer = 0.0
			_try_place_stair_chunk()

func _get_snapped_current_position() -> Vector2:
	var current_map_pos = tile_map.local_to_map(tile_map.to_local(body.global_position))
	return tile_map.to_global(tile_map.map_to_local(current_map_pos))

func _try_place_stair_chunk():
	body.global_position = _get_snapped_current_position()
	
	var total_px = platform_data.platform_size * GridUtils.TILE_SIZE
	var offsets = GridUtils.get_step_offsets(total_px)
	var fixed_y_offset = -GridUtils.TILE_SIZE + 4
	
	var empty_slots = offsets.map(
		func(offset): 
			var global_p = body.global_position + Vector2(initial_direction * offset, fixed_y_offset)
			return tile_map.local_to_map(tile_map.to_local(global_p))
	).filter(
		func(map_pos): return tile_map.get_cell_source_id(map_pos) == -1
	)

	if empty_slots.is_empty():
		start_x = body.global_position.x
		start_y = body.global_position.y
		is_walking_to_pos = true
		return

	if platforms_left < empty_slots.size():
		return _finish_building()

	for map_pos in empty_slots:
		tile_map.set_cell(map_pos, platform_data.source_id, platform_data.atlas_coords)
		platforms_left -= 1

	# Save initial position
	start_x = body.global_position.x
	start_y = body.global_position.y
	is_walking_to_pos = true


func _finalize_step():
	is_walking_to_pos = false
	
	var target_y = start_y - GridUtils.TILE_SIZE
	var target_x = start_x + (initial_direction * (platform_data.platform_size * GridUtils.TILE_SIZE))
	
	var final_y = target_y + (4.1)
	var map_pos = tile_map.local_to_map(tile_map.to_local(Vector2(target_x, target_y + 2)))
	var snapped_x = tile_map.to_global(tile_map.map_to_local(map_pos)).x
	
	body.global_position = Vector2(snapped_x, final_y)
	body.velocity = Vector2.ZERO 
	
	if platforms_left <= 0:
		_finish_building()

func _finish_building():
	is_building = false
	is_walking_to_pos = false
	finished_building.emit()

func stop_action():
	is_building = false
	is_walking_to_pos = false
	body.modulate = Color.WHITE
