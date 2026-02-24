extends Node

# Arraste a cena do seu Walker (32x32) para aqui no Inspetor
@export var walker_scene: PackedScene
@export var spawn_point: Marker2D

func _ready() -> void:
	spawn.call_deferred()

#func _on_spawn_timer_timeout() -> void:
	#spawn()

func spawn() -> void:
	if walker_scene and spawn_point:
		var human_walker = walker_scene.instantiate() as HumanWalker
		get_tree().current_scene.add_child(human_walker)
		human_walker.global_position = spawn_point.global_position
		human_walker.add_to_group("walkers")



func _on_spawn_btn_pressed() -> void:
	spawn()
