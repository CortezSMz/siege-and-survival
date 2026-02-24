class_name HumanWalker extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var head_label: Label = $Label

@onready var walker_component: WalkerComponent = $WalkerComponent
@onready var raycast_component: RaycastComponent = $RaycastComponent
@onready var input_component: InputComponent = $InputComponent

@onready var animation_tree: AnimationTree = $AnimationTree
var direction : int = 1
var want_climb = false

func _physics_process(delta: float) -> void:
	# Auto movement - left to right
	if not want_climb:
		direction = raycast_component.get_direction(direction)
		walker_component.update_direction(direction)
		walker_component.tick(delta)

	# Animation Tree
	if animation_tree:
		animation_tree.set("parameters/walk/blend_position", direction)

	move_and_slide()

func _handle_command(cmd: UI_Handler.UnitCommands):
	head_label.text = UI_Handler.UnitCommands.keys()[cmd][0]

	match cmd:
		UI_Handler.UnitCommands.CLIMB:
			want_climb = true

	input_component.handle(cmd)

func _on_climb_component_finished_climbing() -> void:
	want_climb = false
