extends "res://src/ship_controllers/computer/states/base.gd"

# Fires blaster at target ship


var _target_ship: Ship
var _max_range: float = 300
var _min_range: float = 50


func enter(data: Dictionary = {}) -> void:
	super.enter(data)
	
	assert(data.has("target"), "Persue state was not passed a target ship.")
	assert(data["target"] is Ship, "Persue state was not passed a target ship.")
	
	_target_ship = data["target"] as Ship
	_target_ship.destroyed.connect(_on_target_ship_destroyed)


func exit() -> void:
	super.exit()
	controller.is_fire_commanded = false
	_target_ship.destroyed.disconnect(_on_target_ship_destroyed)


func physics_update(_delta: float) -> void:
	if is_instance_valid(_target_ship):
		_check_fire()
		var dist: float = _target_ship.distance_to_ship(my_ship)
		_check_distance(dist)
		if dist < 100:
			_evade_check()
		_update_direction()
	else:
		controller.is_fire_commanded = false


func _on_target_ship_destroyed(_ship_ref: Ship) -> void:
	change_state_request.emit("Pursue", {})


func _check_fire() -> void:
	var target_in_angle: float = controller.direction_target.angle_to(-my_ship.basis.z) < deg_to_rad(10)
	if controller.is_fire_commanded and !target_in_angle:
		controller.is_fire_commanded = false
	elif !controller.is_fire_commanded and target_in_angle:
		controller.is_fire_commanded = true
		controller.fire_weapon_command.emit()


func _check_distance(dist: float) -> void:
	if dist > _max_range:
		change_state_request.emit("Pursue", {"target": _target_ship})
	elif dist <= _min_range:
		change_state_request.emit("Evade", {"threat": _target_ship})


func _evade_check() -> void:
	var dot: float = -_target_ship.basis.z.dot(-my_ship.basis.z)
	if dot < -0.95:
		change_state_request.emit("Evade", {"threat": _target_ship})


func _update_direction() -> void:
	controller.direction_target = my_ship.global_position.direction_to(
			controller.calc_target_intercept_point(_target_ship)
	)
