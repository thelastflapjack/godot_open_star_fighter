@tool
extends Path3D
class_name HoopPath

signal hoop_collected

@export var _hoop_tscn: PackedScene = preload("res://src/hoop_path/hoop/hoop.tscn")
@export var _hoop_count: int = 5:
	set(value):
		_hoop_count = value
		_clear_hoops()
		_spawn_hoops()


func _ready():
	_clear_hoops()
	_spawn_hoops()


func get_hoop_count() -> int:
	return _hoop_count


func _on_hoop_collected() -> void:
	hoop_collected.emit()


func _clear_hoops() -> void:
	for hoop in get_children():
		if not Engine.is_editor_hint():
			hoop.collected.disconnect(_on_hoop_collected)
		hoop.queue_free()


func _spawn_hoops() -> void:
	var hoop_interval: float = curve.get_baked_length() / _hoop_count
	for i in range(_hoop_count):
		var point_transform: Transform3D = curve.sample_baked_with_rotation(
				i * hoop_interval, true, true
		)
		var new_hoop: Hoop = _hoop_tscn.instantiate()
		add_child(new_hoop)
		new_hoop.transform = point_transform
		
		if not Engine.is_editor_hint():
			new_hoop.collected.connect(_on_hoop_collected)
