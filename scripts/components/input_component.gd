class_name InputComponent extends Node2D

@onready var climb_component: ClimbComponent = $"../ClimbComponent"
@export var head_label : Label

func handle(cmd: UI_Handler.UnitCommands):	
	match cmd:
		UI_Handler.UnitCommands.CLIMB:
			climb_component.climb()
		UI_Handler.UnitCommands.PARACHUTE:
			pass
		UI_Handler.UnitCommands.BUILD:
			pass
		UI_Handler.UnitCommands.DESTROY:
			pass



func _on_climb_component_finished_climbing() -> void:
	head_label.text = ""
