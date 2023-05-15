extends "res://src/ship_controllers/computer/states/base.gd"

# Steers the ship towards a target ship


var _target_ship: Ship
var _attack_range: float = 250


func enter(data: Dictionary = {}) -> void:
	super.enter(data)
	if data != {}:
		assert(data["target"] is Ship, "Persue state was not passed a target ship.")
		_target_ship = data["target"] as Ship
		_target_ship.destroyed.connect(_on_target_ship_destroyed)
	else:
		_target_ship = ShipRegistry.rand_enemy_ship(my_ship.team)
		if _target_ship == null:
			change_state_request.emit("Wander", {})
		else:
			_target_ship.destroyed.connect(_on_target_ship_destroyed)


func exit() -> void:
	super.exit()
	if _target_ship:
		_target_ship.destroyed.disconnect(_on_target_ship_destroyed)


func physics_update(_delta: float) -> void:
	if is_instance_valid(_target_ship):
		_check_distance()
		controller.direction_target = my_ship.direction_to_ship(_target_ship)
	
	var threat_ship: Ship = _check_threats()
	if threat_ship != _target_ship and threat_ship != null:
		change_state_request.emit("Evade", {"threat": threat_ship})


func _on_target_ship_destroyed(_ship_ref: Ship) -> void:
	_target_ship.destroyed.disconnect(_on_target_ship_destroyed)
	_retarget()


func _check_distance() -> void:
	var dist: float = _target_ship.distance_to_ship(my_ship)
	if dist < _attack_range:
		change_state_request.emit("Attack", {"target": _target_ship})


func _retarget() -> void:
	_target_ship = ShipRegistry.rand_enemy_ship(my_ship.team)
	if _target_ship == null:
		change_state_request.emit("Wander", {})
	else:
		_target_ship.destroyed.connect(_on_target_ship_destroyed)

