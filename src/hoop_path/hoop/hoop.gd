extends StaticBody3D
class_name Hoop

signal collected

var _is_collected: bool = false

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

func _on_trigger_area_body_entered(_body: Node3D):
	if not _is_collected:
		_is_collected = true
		_anim_player.play("passed")
		collected.emit()
