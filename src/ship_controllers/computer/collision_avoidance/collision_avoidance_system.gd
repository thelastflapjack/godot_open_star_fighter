extends Node3D
class_name CollisionAvoidanceSys

# Not amazing, but better than nothing. Can avoid most collisions with environment


var _all_casts: Array[RayCast3D]


func _ready():
	for child in get_children():
		var ray: RayCast3D = child as RayCast3D
		_all_casts.append(ray)


func add_collision_exception(body: PhysicsBody3D) -> void:
	for ray in _all_casts:
		ray.add_exception(body)


func set_ray_length(length: float) -> void:
	for ray in _all_casts:
		ray.target_position = ray.target_position.normalized() * length


func avoid_steer_direction() -> Vector3:
	var is_collision_detected: bool = false
	var bad_dir: Vector3 = Vector3.ZERO
	for ray in _all_casts:
		if ray.is_colliding():
			is_collision_detected = true
			bad_dir += to_local(ray.to_global(ray.target_position))
	
	bad_dir = bad_dir.normalized()
	if is_collision_detected:
		var steer_dir: Vector3 = (Vector3.FORWARD - bad_dir)
		if steer_dir.is_equal_approx(Vector3.ZERO):
			return Vector3.UP
		else:
			return steer_dir
	else:
		return Vector3.FORWARD

