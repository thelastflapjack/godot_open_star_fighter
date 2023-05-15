extends Node3D
class_name Missile

var turn_speed: float
var max_time: float = 20
var speed: float = 70
var target: Node3D
var direction: Vector3
var source: Node3D
var damage: int

@onready var _raycast: RayCast3D = $RayCast3D


func _ready() -> void:
	_raycast.add_exception(source)
	
	var life_timer: Timer = $Timer
	life_timer.wait_time = max_time
	life_timer.start()


func _physics_process(delta: float) -> void:
	if target && is_instance_valid(target):
		_update_direction(delta)
	_move(delta)


func _on_life_timer_timeout() -> void:
	queue_free()


func _update_direction(delta: float) -> void:
	var target_direction: Vector3 = (target.global_position - global_position).normalized()
	direction = direction.move_toward(target_direction, turn_speed * delta).normalized()
	look_at(global_position + direction, Vector3.UP)


func _move(delta: float) -> void:
	var frame_move_vector = -basis.z * speed * delta
	_raycast.target_position = to_local(global_position - frame_move_vector)
	_raycast.force_raycast_update()
	
	var collider: Node3D = _raycast.get_collider()
	if collider != null:
		if collider.has_method("take_weapon_damage"):
			collider.take_weapon_damage(damage)
		queue_free()
		
	global_position += frame_move_vector

