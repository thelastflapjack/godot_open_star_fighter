extends "res://src/ship_controllers/computer/states/base.gd"

# Activate afterburn in current diretion for a period of time

var _flee_timer: Timer
var _flee_time: float = 6



func _ready() -> void:
	_flee_timer = Timer.new()
	_flee_timer.one_shot = true
	_flee_timer.wait_time = _flee_time
	add_child(_flee_timer)
	_flee_timer.timeout.connect(_on_flee_timer_timeout)


func enter(_data: Dictionary = {}) -> void:
	super.enter()
	controller.is_afterburn_commanded = true
	controller.direction_target = -my_ship.basis.z
	_flee_timer.start()


func _on_flee_timer_timeout():
	controller.is_afterburn_commanded = false
	_flee_timer.stop()
	change_state_request.emit("Pursue", {})

