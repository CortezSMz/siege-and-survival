class_name UI_Handler extends Node2D

@onready var command_buttons = {
	UnitCommands.WALKER: %BtnWalker,
	UnitCommands.BLOCKER: %BtnBlocker,
	UnitCommands.CLIMBER: %BtnClimber,
	UnitCommands.FLOATER: %BtnFloater,
	UnitCommands.EXPLODER: %BtnExploder,
	UnitCommands.BUILDER_SIDES: %BtnBuilderSides,
	UnitCommands.BUILDER_DIAG_UP: %BtnBuilderDiagUp,
	UnitCommands.BUILDER_DIAG_DOWN: %BtnBuilderDiagDown,
	UnitCommands.MINER_SIDES: %BtnMinerSides,
	UnitCommands.MINER_DOWN: %BtnMinerDown,
	UnitCommands.MINER_DIAG_UP: %BtnMinerDiagUp,
	UnitCommands.MINER_DIAG_DOWN: %BtnMinerDiagDown,
}
enum UnitCommands {
	WALKER, BLOCKER, CLIMBER, FLOATER, EXPLODER,
	BUILDER_SIDES, BUILDER_DIAG_UP, BUILDER_DIAG_DOWN,
	MINER_SIDES, MINER_DOWN, MINER_DIAG_UP, MINER_DIAG_DOWN
}
@export var unit_commands: UnitCommands
var current_command : UnitCommands = UnitCommands.WALKER

# DEBUG UI ELEMENTS
static var debug_collisions_enabled : bool = false
static var debug_grid_enabled : bool = false
static var debug_show_states_enabled : bool = false

func _ready() -> void:
	%GameSpeedLabel.text = '1.0x speed'

	get_tree().debug_collisions_hint = debug_collisions_enabled
	%ToggleCollisions.set_pressed_no_signal(debug_collisions_enabled)

	%ToggleGrid.set_pressed_no_signal(debug_grid_enabled)
	var grid = %DebugGrid
	if grid: grid.visible = debug_grid_enabled

	%ToggleShowStates.set_pressed_no_signal(debug_show_states_enabled)

func _process(_delta: float) -> void:
	_update_tile_inspector()


##### UI BUTTON EVENTS #####
func _on_btn_walker_pressed() -> void: _select_cmd(UnitCommands.WALKER)
func _on_btn_blocker_pressed() -> void: _select_cmd(UnitCommands.BLOCKER)
func _on_btn_climber_pressed() -> void: _select_cmd(UnitCommands.CLIMBER)
func _on_btn_floater_pressed() -> void: _select_cmd(UnitCommands.FLOATER)
func _on_btn_exploder_pressed() -> void: _select_cmd(UnitCommands.EXPLODER)
func _on_btn_builder_sides_pressed() -> void: _select_cmd(UnitCommands.BUILDER_SIDES)
func _on_btn_builder_diag_up_pressed() -> void: _select_cmd(UnitCommands.BUILDER_DIAG_UP)
func _on_btn_builder_diag_down_pressed() -> void: _select_cmd(UnitCommands.BUILDER_DIAG_DOWN)
func _on_btn_miner_sides_pressed() -> void: _select_cmd(UnitCommands.MINER_SIDES)
func _on_btn_miner_down_pressed() -> void: _select_cmd(UnitCommands.MINER_DOWN)
func _on_btn_miner_diag_up_pressed() -> void: _select_cmd(UnitCommands.MINER_DIAG_UP)
func _on_btn_miner_diag_down_pressed() -> void: _select_cmd(UnitCommands.MINER_DIAG_DOWN)

func _select_cmd(cmd: UnitCommands):
	current_command = cmd
	print("Command: ", UnitCommands.keys()[current_command])

	for c in command_buttons:
		var btn = command_buttons[c]
		btn.self_modulate = Color(0.0, 0.775, 0.573, 1.0) if c == current_command else Color.WHITE


##### DEBUG METHODS #####
func _on_toggle_collisions_toggled(toggled_on: bool) -> void:
	debug_collisions_enabled = toggled_on
	get_tree().debug_collisions_hint = toggled_on
	get_tree().reload_current_scene()

func _on_btn_clear_walkers_pressed() -> void:
	get_tree().call_group("walkers", "queue_free")

func _on_btn_reset_level_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _on_edit_speed_value_changed(value: float) -> void:
	Engine.time_scale = value
	%GameSpeedLabel.text = str(value) + 'x speed'

func _on_btn_reset_game_speed_pressed() -> void:
	Engine.time_scale = 1.0
	%SliderEditSpeed.value = 1.0
	%GameSpeedLabel.text = '1.0x speed'
	


func _update_tile_inspector() -> void:
	var map = get_tree().get_first_node_in_group("level_tilemap") as TileMapLayer
	if map and %LblTileCoords:
		var cell = map.local_to_map(map.get_local_mouse_position())
		%LblTileCoords.text = str(cell)

func _on_toggle_grid_toggled(toggled_on: bool) -> void:
	var grid = %DebugGrid
	if grid: grid.visible = toggled_on
	debug_grid_enabled = toggled_on

func _on_toggle_show_states_toggled(toggled_on: bool) -> void:
	debug_show_states_enabled = toggled_on


##### CLICK EVENTS #####
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		find_closest_walker(get_global_mouse_position())

func find_closest_walker(pos) -> void:
	var walkers = get_tree().get_nodes_in_group("walkers")
	var closest_unit : HumanWalker = null
	var min_dist = 50.0

	for w in walkers:
		var dist = pos.distance_to(w.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_unit = w
			
	if closest_unit:
		closest_unit._handle_command(current_command)
