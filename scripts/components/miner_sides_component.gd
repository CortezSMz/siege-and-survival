class_name MinerSidesComponent extends Node

signal finished_mining

@export var body : CharacterBody2D
@export var walker_component : WalkerComponent
@export var mine_time : float = 0.5 

@onready var raycast_component: RaycastComponent = %RaycastComponent

var tile_map : TileMapLayer
var is_mining : bool = false
var mine_timer : float = 0.0

var is_walking_to_pos : bool = false
var start_x : float = 0.0
var initial_direction : int = 0


func setup():
	body.modulate = Color.BROWN
	is_mining = false
	is_walking_to_pos = false
	mine_timer = 0.0
	tile_map = get_tree().get_first_node_in_group("level_tilemap")


func execute(delta: float):
	if not body or not tile_map: return

	# Natural movement
	if is_walking_to_pos:
		# Force direction before and after walking
		walker_component.direction = initial_direction 
		walker_component.execute(delta)
		walker_component.direction = initial_direction 
		
		var distance_traveled = abs(body.global_position.x - start_x)
		
		if distance_traveled >= 15.5: 
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
	
	# Clear 2 columns ahead
	for offset_x in [8, 16]:
		for offset_y in range(-2, 2): 
			var target_pos = body.global_position + Vector2(dir * offset_x, (offset_y * 8) - 12)
			var map_pos = tile_map.local_to_map(tile_map.to_local(target_pos))
			tile_map.set_cell(map_pos, -1)

	start_x = body.global_position.x
	is_walking_to_pos = true
	is_mining = false


func _finalize_step():
	is_walking_to_pos = false

	body.global_position.x = start_x + (initial_direction * 16)
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
