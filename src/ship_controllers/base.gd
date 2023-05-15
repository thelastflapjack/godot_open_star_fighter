extends Node
class_name ShipControllerBase

signal change_weapon_mode_command(mode: Ship.WeaponMode)
signal fire_weapon_command()
signal afterburner_command()

var direction_target: Vector3
var roll_command: float
var is_fire_commanded: bool = false
var is_afterburn_commanded: bool = false

@onready var _ship: Ship = get_parent()



# CONSIDER: Move to a general function static class
func calc_target_intercept_point(target_ship: Ship) -> Vector3:
	# Parameters
	var target_position: Vector3 = target_ship.global_position
	var target_velocity: Vector3 = target_ship.current_velocity()
	var my_position: Vector3 = _ship.global_position
	var blaster_speed: float = _ship.get_current_blaster_speed()
	var relative_position = target_position - my_position
	
	# Quadratic equation values
	var a: float = target_velocity.dot(target_velocity) - (blaster_speed * blaster_speed)
	var b: float = 2.0 * target_velocity.dot(relative_position)
	var c: float = relative_position.dot(relative_position)
	
	var p: float = -b / (2 * a)
	var q: float = sqrt((b * b) - 4 * a * c) / (2 * a)
	
	var t1: float = p - q
	var t2: float = p + q
	var solution_time: float = t1
	
	if t1 > t2 and t2 > 0:
		solution_time = t2
	
	var lead_solution = target_velocity * solution_time
	return target_position + lead_solution
