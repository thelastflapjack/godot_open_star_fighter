extends Node3D
class_name BlasterBolt


var damage: float
var velocity: Vector3
var source: Node3D
var max_range: float

var _lifetime_travel: float

@onready var _raycast: RayCast3D = $RayCast3D


func _ready() -> void:
	_raycast.add_exception(source)


func _physics_process(delta: float):
	var frame_move_vector: Vector3 = velocity * delta
	_raycast.target_position = to_local(global_position + frame_move_vector)
	_raycast.force_raycast_update()
	
	var collider: Node3D = _raycast.get_collider()
	if collider != null:
		if collider.has_method("take_weapon_damage"):
			collider.take_weapon_damage(damage)
		queue_free()
	
	global_position += frame_move_vector
	_lifetime_travel += frame_move_vector.length()
	
	if _lifetime_travel > max_range:
		queue_free()
