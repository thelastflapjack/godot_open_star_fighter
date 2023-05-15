extends Node3D
class_name GameCameraRig


@export var _look_ahead_offset: int = 200
@export var _cam_follow_smoothing: float = 5.0
@export var _cockpit_cam_smoothing: float = 25
@export var _fov_min: float = 75
@export var _fov_max: float = 85
@export var _tracked_ship: Ship
@export var _cockpit_view: bool = true


@onready var _cam: Camera3D = $Camera3D
@onready var _cockpit_mesh: MeshInstance3D = $CockpitMesh
@onready var _particles_root: Node3D = $ParticlesRoot
@onready var _fov_range: float = _fov_max - _fov_min



func _physics_process(delta: float):
	if is_instance_valid(_tracked_ship):
		if _cockpit_view:
			global_position = _tracked_ship.global_position
			_particles_root.global_transform = _tracked_ship.global_transform
			_cockpit_mesh.global_rotation = _tracked_ship.global_rotation
			
			var start_rot: Vector3 = _cam.global_rotation
			var end_rot: Vector3 = _tracked_ship.global_rotation
			var lerp_weight: float = _cockpit_cam_smoothing * delta
			_cam.global_rotation = Vector3(
					lerp_angle(start_rot.x, end_rot.x, lerp_weight),
					lerp_angle(start_rot.y, end_rot.y, lerp_weight),
					lerp_angle(start_rot.z, end_rot.z, lerp_weight)
			)
		else:
			global_position = lerp(
					global_position, _tracked_ship.global_position, 
					_cam_follow_smoothing * delta
			)
			global_rotation = _tracked_ship.global_rotation
			
			var look_point: Vector3 = _tracked_ship.global_position - (_tracked_ship.basis.z * _look_ahead_offset)
			_cam.look_at(look_point, _tracked_ship.basis.y)
		
		_cam.fov = _fov_min + (_fov_range * _tracked_ship.get_speed_ratio())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_switch_view"):
		_switch_view()


func get_cam_ref() -> Camera3D:
	return _cam


func set_tracked_ship(new_ship: Ship) -> void:
	_tracked_ship = new_ship
	
	_tracked_ship.show_ship_mesh(!_cockpit_view)
	_cockpit_mesh.visible = _cockpit_view


func _switch_view() -> void:
	_cockpit_view = !_cockpit_view
	_tracked_ship.show_ship_mesh(!_cockpit_view)
	_cockpit_mesh.visible = _cockpit_view
	
	if !_cockpit_view:
		_cam.position = Vector3(0 , 4.093, 13.318) # TODO: Make this a marker3d node
	else:
		_cam.position = Vector3.ZERO
		var look_point: Vector3 = _tracked_ship.global_position - _tracked_ship.basis.z
		_cam.look_at(look_point, _tracked_ship.basis.y)

