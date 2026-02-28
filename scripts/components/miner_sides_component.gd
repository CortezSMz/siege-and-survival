class_name MinerSidesComponent extends Node

signal finished_mining

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var mine_time : float = 0.5
@export var column_size : int = 1:
	set(value):
		column_size = value
		column_size_px = GridUtils.to_px(value)
var column_size_px: float = GridUtils.TILE_SIZE

@onready var raycast_component: RaycastComponent = %RaycastComponent

var tile_maps : Array = []
var is_mining : bool = false
var mine_timer : float = 0.0

var is_walking_to_pos : bool = false
var start_x : float = 0.0
var initial_direction : int = 0


func setup():
	body.modulate = Color.BROWN
	column_size_px = GridUtils.to_px(column_size)
	is_mining = false
	is_walking_to_pos = false
	mine_timer = 0.0
	tile_maps = get_tree().get_nodes_in_group("destructible_tilemap")


func execute(delta: float):
	if not body or tile_maps.is_empty(): return

	# Natural movement
	if is_walking_to_pos:
		# Force direction before and after walking
		walker_component.direction = initial_direction 
		walker_component.execute(delta)
		walker_component.direction = initial_direction 
		
		var distance_traveled = abs(body.global_position.x - start_x)
		
		if distance_traveled >= (column_size_px - 0.5):
			_finalize_step()
		return

	# Searching wall phase
	if not is_mining:
		# Check wall before walking
		if raycast_component.get_direction(walker_component.direction) != walker_component.direction:
			is_mining = true
			initial_direction = walker_component.direction
			body.velocity = Vector2.ZERO
			return
			
		walker_component.execute(delta)

	# Mining phase
	else:
		mine_timer += delta
		if mine_timer >= mine_time:
			mine_timer = 0.0
			_try_dig()


func _try_dig():
	var dir = initial_direction

	for tm in tile_maps:
		if not tm is TileMapLayer: continue
		for offset_x in GridUtils.get_step_offsets(column_size_px):
			for offset_y in range(-2, 2):
				var target_pos = body.global_position + Vector2(dir * offset_x, (offset_y * GridUtils.TILE_SIZE) - 12.0)
				var map_pos = tm.local_to_map(tm.to_local(target_pos))
				tm.set_cell(map_pos, -1)

	start_x = body.global_position.x
	is_walking_to_pos = true
	is_mining = false


func _finalize_step():
	is_walking_to_pos = false

	body.global_position.x = start_x + (initial_direction * column_size_px)
	body.velocity.x = 0
	
	# Check if there's walls left to mine, else finish mining
	if raycast_component.get_direction(initial_direction) != initial_direction:
		is_mining = true
	else:
		_finish_mining()


func _finish_mining():
	is_mining = false
	is_walking_to_pos = false
	finished_mining.emit()


func stop_action():
	is_mining = false
	is_walking_to_pos = false
	body.modulate = Color.WHITE
