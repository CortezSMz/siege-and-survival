class_name UI_Handler extends Node2D

enum UnitCommands {
	NONE,
	CLIMB,
	PARACHUTE,
	BUILD,
	DESTROY,
}
@export var unit_commands: UnitCommands
var current_command : UnitCommands = UnitCommands.NONE

##### UI BUTTON EVENTS #####
func _on_btn_climb_pressed() -> void:
	current_command = UnitCommands.CLIMB
	print("Command: ", UnitCommands.keys()[current_command])

func _on_btn_parachute_pressed() -> void:
	current_command = UnitCommands.PARACHUTE
	print("Command: ", UnitCommands.keys()[current_command])

func _on_btn_build_pressed() -> void:
	current_command = UnitCommands.BUILD
	print("Command: ", UnitCommands.keys()[current_command])

func _on_btn_destroy_pressed() -> void:
	current_command = UnitCommands.DESTROY
	print("Command: ", UnitCommands.keys()[current_command])


##### CLICK EVENTS #####
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_global_mouse_position()
		find_closest_walker(pos)

func find_closest_walker(pos) -> void:
	var walkers = get_tree().get_nodes_in_group("walkers")
	var closest_unit : HumanWalker = null
	var min_dist = 50.0 # Raio máximo de tolerância (em pixels)

	for w in walkers:
		var dist = pos.distance_to(w.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_unit = w
			
	if closest_unit:
		print("Command " + UI_Handler.UnitCommands.keys()[current_command] + " applied to " +str(self) )
		closest_unit._handle_command(current_command)
