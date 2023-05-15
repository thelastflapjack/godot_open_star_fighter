@icon("res://node_icons/processor.svg") #https://game-icons.net/1x1/lorc/processor.html
extends ShipControllerBase
class_name ShipControllerComputer


### Private variables ###
var _threat_ships: Array[Ship]

### Onready variables ###
@onready var _state_machine: StateMachine = $StateMachine
@onready var _threat_detection_area: Area3D = $ThreatDetectionArea
@onready var _collision_avoidance_sys: CollisionAvoidanceSys = $CollisionAvoidanceSystem


############################
# Engine Callback Methods  #
############################

func _ready() -> void:
	for child in _state_machine.get_children():
		var state: ShipControllerComputerState = child
		state.controller = self
		state.my_ship = _ship
		state.threat_detection_area = _threat_detection_area
	
	_collision_avoidance_sys.add_collision_exception(_ship)
	_collision_avoidance_sys.set_ray_length(70)
	
	_state_machine.initalize()


func _physics_process(delta: float) -> void:
	_threat_detection_area.global_position = _ship.global_position
	_collision_avoidance_sys.global_transform = _ship.global_transform
	
	_state_machine.physics_update(delta)
	_avoid_collision()


############################
#	  Public Methods	  #
############################

func get_threat_ships() -> Array[Ship]:
	return _threat_ships

############################
# Signal Connected Methods #
############################
func _on_threat_detection_area_body_entered(body: Node3D):
	var threat_ship: Ship =  body as Ship
	if threat_ship.team != _ship.team:
		_threat_ships.append(threat_ship)


func _on_threat_detection_area_body_exited(body: Node3D):
	var threat_ship: Ship =  body as Ship
	if threat_ship.team != _ship.team:
		_threat_ships.erase(threat_ship)


############################
#	  Private Methods	 #
############################
func _avoid_collision() -> void:
	var safe_dir: Vector3 = _collision_avoidance_sys.avoid_steer_direction()
	if safe_dir != Vector3.FORWARD:
		direction_target = (direction_target + safe_dir).normalized()

