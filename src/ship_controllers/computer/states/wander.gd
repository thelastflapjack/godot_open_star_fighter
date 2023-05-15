extends "res://src/ship_controllers/computer/states/base.gd"

# Steers the ship in a random direction every so often


var _wander_timer: Timer
var _max_steer: float = 1
var _wander_interval_min: float = 4
var _wander_interval_max: float = 8
var _wander_direction: Vector3



func _ready() -> void:
	_wander_timer = Timer.new()
	_wander_timer.one_shot = true
	add_child(_wander_timer)
	_wander_timer.timeout.connect(_update_wander_direction)


func enter(_data: Dictionary = {}) -> void:
	super.enter()
	_update_wander_direction()


func physics_update(_delta: float) -> void:
	controller.direction_target = (-my_ship.basis.z + _wander_direction).normalized()


func _update_wander_direction() -> void:
	var rand_dir = (
		(my_ship.basis.y * randf_range(-_max_steer, _max_steer)) + 
		(my_ship.basis.x * randf_range(-_max_steer, _max_steer))
	)
	
	_wander_direction = rand_dir.normalized()
	
	_wander_timer.start(randf_range(_wander_interval_min, _wander_interval_max))

