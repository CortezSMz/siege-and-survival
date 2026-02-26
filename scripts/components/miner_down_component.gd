class_name MinerDownComponent extends Node

signal finished_mining

@export var body : CharacterBody2D
@export var mine_time : float = 0.6
@export var step_height : float = GridUtils.TILE_SIZE

var tile_map : TileMapLayer
var is_mining : bool = false
var mine_timer : float = 0.0

# Vertical Natural Movement
var is_descending : bool = false
var start_y : float = 0.0

func setup():
	body.modulate = Color.DARK_SLATE_GRAY
	is_mining = true
	is_descending = false
	mine_timer = 0.0
	body.velocity = Vector2.ZERO
	tile_map = get_tree().get_first_node_in_group("level_tilemap")

func execute(delta: float):
	if not body or not tile_map: return

	# 1. Movimento Natural (Descendo os 16px)
	if is_descending:
		body.global_position.y += 60 * delta # Velocidade de descida
		
		var distance_traveled = abs(body.global_position.y - start_y)
		
		if distance_traveled >= (step_height - 0.5):
			_finalize_step()
		return

	# 2. Fase de Mineração (Esperando o "timer" da picareta)
	mine_timer += delta
	if mine_timer >= mine_time:
		mine_timer = 0.0
		_try_dig_down()

func _try_dig_down():
	# Limpa uma área de 16px de largura (2 tiles) abaixo dos pés
	# Usamos offset_x de -4 e 4 para pegar os dois tiles centrais sob o boneco
	for x_offset in [-4, 4]:
		for y_offset in GridUtils.get_step_offsets(step_height):
			var target_pos = body.global_position + Vector2(x_offset, y_offset)
			var map_pos = tile_map.local_to_map(tile_map.to_local(target_pos))
			tile_map.set_cell(map_pos, -1)

	# Inicia a descida para o próximo nível
	start_y = body.global_position.y
	is_descending = true

func _finalize_step():
	is_descending = false
	
	# Snap exato no Y para manter o alinhamento de 8px
	body.global_position.y = start_y + step_height
	
	# Checa se ainda há chão para cavar
	if _has_ground_below():
		is_mining = true
	else:
		# Se cavou e caiu no "céu" (vazio), termina a ação
		_finish_mining()

func _has_ground_below() -> bool:
	# Checa se há qualquer tile nos próximos 8px abaixo
	for x_offset in [-4, 4]:
		var target_pos = body.global_position + Vector2(x_offset, GridUtils.TILE_SIZE)
		var map_pos = tile_map.local_to_map(tile_map.to_local(target_pos))
		if tile_map.get_cell_source_id(map_pos) != -1:
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
