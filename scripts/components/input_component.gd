class_name InputComponent extends Node2D

signal command_executing

@onready var components = {
	UI_Handler.UnitCommands.CLIMB: %ClimbComponent,
	UI_Handler.UnitCommands.PARACHUTE: %ParachuteComponent,
	UI_Handler.UnitCommands.STOP: %StopComponent,
}

@export var head_label : Label

var curr_cmd = UI_Handler.UnitCommands.WALK

func handle(new_cmd: UI_Handler.UnitCommands):
	if new_cmd == curr_cmd:
		return

	if components.has(curr_cmd):
		components[curr_cmd].stop()

	curr_cmd = new_cmd
	
	if components.has(new_cmd):
		var comp = components[new_cmd]

		head_label.text = UI_Handler.UnitCommands.keys()[new_cmd][0]
		
		if comp.has_method("start_action"):
			comp.start_action()
			command_executing.emit()
	else:
		head_label.text = ""



func _on_climb_component_finished_climbing() -> void:
	curr_cmd = UI_Handler.UnitCommands.WALK
	head_label.text = ""

func _on_parachute_component_finished_parachuting() -> void:
	curr_cmd = UI_Handler.UnitCommands.WALK
	head_label.text = ""

func _on_stop_component_finished_blocking() -> void:
	curr_cmd = UI_Handler.UnitCommands.WALK
	head_label.text = ""
