extends "res://src/ship_controllers/computer/states/base.gd"

# Steers the ship in a random direction every so often


### Private variables ###
var _evade_timer: Timer
var _steer_max: float = 5
var _steer_min: float = 3
var _evade_interval_min: float = 1
var _evade_interval_max: float = 2
var _evade_direction: Vector3
var _threat_ship: Ship
var _safe_range: float = 200


func _ready() -> void:
	_evade_timer = Timer.new()
	_evade_timer.one_shot = true
	add_child(_evade_timer)
	_evade_timer.timeout.connect(_on_evade_timer_timeout)


func enter(data: Dictionary = {}) -> void:
	super.enter(data)
	
	assert(data.has("threat"), "Evade state was not passed a threat ship.")
	assert(data["threat"] is Ship, "Evade state was not passed a threat ship.")
	
	_threat_ship = data["threat"] as Ship
	_threat_ship.destroyed.connect(_on_threat_ship_destroyed)
	
	_update_evade_direction()


func exit() -> void:
	super.exit()
	if is_instance_valid(_threat_ship):
		_threat_ship.destroyed.disconnect(_on_threat_ship_destroyed)


func physics_update(_delta: float) -> void:
	if is_instance_valid(_threat_ship):
		controller.direction_target = _evade_direction
		
		# CONSIDER: Poll these checks with a timer later. Don't need to do them every phys frame
		if _has_evaded():
			change_state_request.emit("Flee", {})
		elif my_ship.distance_to_ship(_threat_ship) > _safe_range:
			change_state_request.emit("Pursue", {})


func _on_threat_ship_destroyed(_ship_ref: Ship) -> void:
	_threat_ship.destroyed.disconnect(_on_threat_ship_destroyed)
	_threat_ship = null
	change_state_request.emit("Pursue", {})


func _on_evade_timer_timeout() -> void:
	if is_instance_valid(_threat_ship):
		_update_evade_direction()
	else:
		change_state_request.emit("Pursue", {})


func _update_evade_direction() -> void:
	var _away_vector: Vector3 = -my_ship.direction_to_ship(_threat_ship)
	# steers will be between -_steer_min and -_steer_max or between _steer_min and _steer_max
	# this is to ensure the angle of _evade_direction isn't too small
	var _steer_y: float = randf_range(_steer_min, _steer_max) * sign(randf_range(-1, 1))
	var _steer_x: float = randf_range(_steer_min, _steer_max) * sign(randf_range(-1, 1))
	var rand_dir = (
		(my_ship.basis.y * _steer_y) + (my_ship.basis.x * _steer_x)
	)
	
	_evade_direction = (_away_vector + rand_dir).normalized()
	_evade_timer.start(randf_range(_evade_interval_min, _evade_interval_max))


func _has_evaded() -> bool:
	var _threat_ship_forward_dir: Vector3 = -_threat_ship.basis.z
	var _threat_vector: Vector3 = _threat_ship.direction_to_ship(my_ship)
	return  _threat_ship_forward_dir.angle_to(_threat_vector) > deg_to_rad(45)

