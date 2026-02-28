class_name MinerDownComponent extends Node

signal finished_mining

@export var body : CharacterBody2D
@export var mine_time : float = 0.6
@export var step_height : int = 1:
	set(value):
		step_height = value
		step_height_px = GridUtils.to_px(value)
var step_height_px : float = GridUtils.TILE_SIZE

var tile_maps : Array = []
var is_mining : bool = false
var mine_timer : float = 0.0

# Vertical Natural Movement
var is_descending : bool = false
var start_y : float = 0.0

func setup():
	body.modulate = Color.DARK_SLATE_GRAY
	step_height_px = GridUtils.to_px(step_height)
	is_mining = true
	is_descending = false
	mine_timer = 0.0
	body.velocity = Vector2.ZERO
	tile_maps = get_tree().get_nodes_in_group("destructible_tilemap")

func execute(delta: float):
	if not body or tile_maps.is_empty(): return

	# Natural movement
	if is_descending:
		body.global_position.y += 60 * delta

		var distance_traveled = abs(body.global_position.y - start_y)

		if distance_traveled >= (step_height_px - 0.5):
			_finalize_step()
		return

	# Mining phase
	mine_timer += delta
	if mine_timer >= mine_time:
		mine_timer = 0.0
		_try_dig_down()

func _try_dig_down():
	for tm in tile_maps:
		if not tm is TileMapLayer: continue
		for x_offset in [-4, 4]:
			for y_offset in GridUtils.get_step_offsets(step_height_px):
				var target_pos = body.global_position + Vector2(x_offset, y_offset)
				var map_pos = tm.local_to_map(tm.to_local(target_pos))
				tm.set_cell(map_pos, -1)

	start_y = body.global_position.y
	is_descending = true

func _finalize_step():
	is_descending = false
	
	body.global_position.y = start_y + step_height_px
	
	if _has_ground_below():
		is_mining = true
	else:
		_finish_mining()

func _has_ground_below() -> bool:
	for tm in tile_maps:
		if not tm is TileMapLayer: continue
		for x_offset in [-4, 4]:
			var target_pos = body.global_position + Vector2(x_offset, GridUtils.TILE_SIZE)
			var map_pos = tm.local_to_map(tm.to_local(target_pos))
			if tm.get_cell_source_id(map_pos) != -1:
				return true
	return false

func _finish_mining():
	is_mining = false
	is_descending = false
	finished_mining.emit()

func stop_action():
	is_mining = false
	is_descending = false
	body.modulate = Color.WHITE
