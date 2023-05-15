extends State
class_name ShipControllerComputerState

# Base state all computer ship controller states inherit from

var controller: ShipControllerComputer
var my_ship: Ship
var threat_detection_area: Area3D


func _check_threats() -> Ship:
	for threat_ship in controller.get_threat_ships():
		var _threat_ship_forward_dir: Vector3 = -threat_ship.basis.z
		var _threat_vector: Vector3 = threat_ship.direction_to_ship(my_ship)
		if _threat_ship_forward_dir.angle_to(_threat_vector) < deg_to_rad(20):
			return threat_ship
	return null

