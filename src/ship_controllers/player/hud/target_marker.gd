extends Control
class_name TargetMarker

var target: Node3D

@onready var _marker_track: TextureRect = $MarkerTrack
@onready var _range_label: Label =  $LabelRange
@onready var _shield_indicator: ColorRect = $ColorRect

func update_track(active: bool) -> void:
	if active:
		_marker_track.modulate = Color("ff6200")
		_range_label.show()
	else:
		_marker_track.modulate = Color.WHITE
		_range_label.hide()


func show_shield_indicator(is_shown: bool) -> void:
	_shield_indicator.visible = is_shown


func update_range(value: int) -> void:
	_range_label.text = str(value)
