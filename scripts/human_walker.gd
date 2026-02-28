class_name HumanWalker extends CharacterBody2D

@onready var head_label: Label = $Label
@onready var walker_component: WalkerComponent = $WalkerComponent
@onready var raycast_component: RaycastComponent = $RaycastComponent
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var components = {
	UI_Handler.UnitCommands.WALKER: %WalkerComponent,
	UI_Handler.UnitCommands.BLOCKER: %BlockerComponent,
	UI_Handler.UnitCommands.CLIMBER: %ClimberComponent,
	UI_Handler.UnitCommands.FLOATER: %FloaterComponent,
	UI_Handler.UnitCommands.EXPLODER: %ExploderComponent,
	UI_Handler.UnitCommands.BUILDER_SIDES: %BuilderSidesComponent,
 	UI_Handler.UnitCommands.BUILDER_DIAG_UP: %BuilderDiagUpComponent,
	# UI_Handler.UnitCommands.BUILDER_DIAG_DOWN: %BuilderDiagDownComponent,
	UI_Handler.UnitCommands.MINER_SIDES: %MinerSidesComponent,
	UI_Handler.UnitCommands.MINER_DOWN: %MinerDownComponent,
	UI_Handler.UnitCommands.MINER_DIAG_UP: %MinerDiagUpComponent,
	# UI_Handler.UnitCommands.MINER_DIAG_DOWN: %MinerDiagDownComponent,
}

var current_command = UI_Handler.UnitCommands.WALKER
var direction : int = 1


func _ready() -> void:
	components[current_command].setup()


## DEBUG LABEL ##
func _process(_delta):
	if UI_Handler.debug_show_states_enabled:
		head_label.text = UI_Handler.UnitCommands.keys()[current_command]
		head_label.visible = true
	if current_command == UI_Handler.UnitCommands.WALKER:
		head_label.visible = false


func _physics_process(delta: float) -> void:
	if components.has(current_command):
		components[current_command].execute(delta)
	
	if animation_tree:
		var dir = %WalkerComponent.direction
		animation_tree.set("parameters/walk/blend_position", dir)

	move_and_slide()


func _handle_command(cmd: UI_Handler.UnitCommands):
	if cmd == current_command or not components.has(cmd):
		return

	components[current_command].stop_action()

	current_command = cmd

	components[current_command].setup()
	
	
##### ON FINISH EVENTS #####
func _on_climber_component_finished_climbing() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_floater_component_finished_floating() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_blocker_component_finished_blocking() -> void:
	pass

func _on_builder_sides_component_finished_building() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_builder_diag_up_component_finished_building() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_builder_diag_down_component_finished_building() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_miner_sides_component_finished_mining() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_miner_down_component_finished_mining() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)

func _on_miner_diag_up_component_finished_mining() -> void:
	_handle_command.call_deferred(UI_Handler.UnitCommands.WALKER)
