extends Node3D
class_name Effect


func _ready():
	var anim_player: AnimationPlayer = $AnimationPlayer
	anim_player.play("start")

