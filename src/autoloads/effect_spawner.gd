extends Node3D

var _explosion_effect_tscn: PackedScene = preload("res://src/effects/explosion_effect.tscn")


func spawn_explosion_effect(spawn_pos: Vector3) -> void:
	var new_effect: Effect = _explosion_effect_tscn.instantiate()
	add_child(new_effect)
	new_effect.global_position = spawn_pos

