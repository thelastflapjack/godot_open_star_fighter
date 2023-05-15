@icon("res://node_icons/ship.svg")
extends CharacterBody3D
class_name Ship

# Docstring

### Signals ###
signal hull_health_chaged(value: int)
signal shield_health_chaged(value: int)
signal destroyed(ref: Ship)
signal missile_lock_target_updated(target: Ship)

### Enums ###
enum WeaponMode {BLASTER, MISSILE}
enum Team {BLUE, RED}


### Exported variables ###
@export_category("Handling - Not per instance") # CONSIDER: Change to resource
@export var _speed_base: float = 30.0
@export var _speed_afterburn: float = 70.0
@export var _acceleration: float = 5;
@export var _steering_speed: float = 1.45
@export var _roll_speed_max: float = 0.025

@export_category("Weapons")
@export var _weapon_blaster: Blaster
@export var _weapon_missile: MissileLauncher

@export_category("Other")
@export var _shield: Shield
@export var team: Team
@export var invulnerable: bool = false



### Private variables ###
var _velocity_target: Vector3 = Vector3.ZERO
var _weapon_mode: WeaponMode = WeaponMode.BLASTER
var _is_alive: bool = true
var _controller: ShipControllerBase
var _max_health: int = 50
var _detected_ships: Array[Ship]
var _missile_lock_target: Ship = null


### Onready variables ###
@onready var _visible_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var _missile_launcher_slot: Marker3D = $WeaponSlots/MissileLauncherPoint
@onready var _weapon_slots_blaster: Array = [
		$WeaponSlots/BlasterSlot1, $WeaponSlots/BlasterSlot2
]
@onready var _timer_fire_blaster_interval: Timer = $TimerFireBlasterInterval
@onready var _timer_fire_missile_interval: Timer = $TimerFireMissileInterval
@onready var _audio_primary_fire: AudioStreamPlayer3D = $AudioPrimary
@onready var _ship_mesh_inst: MeshInstance3D = $ShipMeshInst
@onready var _health: int = _max_health


############################
# Engine Callback Methods  #
############################
func _ready():
	if _weapon_blaster:
		_audio_primary_fire.stream = _weapon_blaster.shoot_audio
	
	if team == Team.RED:
		_ship_mesh_inst.set_material_overlay(preload("res://src/ships/team_red.tres"))
	elif team == Team.BLUE:
		_ship_mesh_inst.set_material_overlay(preload("res://src/ships/team_blue.tres"))
	
	if _shield:
		_shield.health_changed.connect(_on_shield_health_changed)



func _physics_process(delta: float) -> void:
	var new_direction: Vector3 = (-basis.z).move_toward(
			_controller.direction_target, _steering_speed * delta
	)
	look_at(global_position + new_direction, basis.y)
	
	if _weapon_mode == WeaponMode.MISSILE:
		_update_missile_lock() # CONSIDER: Update on timer, don't need to do every physics frame
	
	var speed_target = _speed_base
	if _controller.is_afterburn_commanded:
		speed_target = _speed_afterburn
	_velocity_target = _velocity_target.move_toward(-basis.z * speed_target, _acceleration)
	
	rotate(basis.z, _controller.roll_command * _roll_speed_max)
	basis = basis.orthonormalized()
	
	var collision: KinematicCollision3D = move_and_collide(_velocity_target * delta)
	if collision:
		_die()


############################
#      Public Methods      #
############################
func setup(assigned_team: Team, assigned_controller: ShipControllerBase) -> void:
	team = assigned_team
	ShipRegistry.register(self)
	
	_controller = assigned_controller
	add_child(_controller)
	_controller.change_weapon_mode_command.connect(_on_controller_change_weapon_mode_command)
	_controller.fire_weapon_command.connect(_on_controller_fire_weapon_command)


func get_speed_base() -> float:
	return _speed_base


func get_speed_afterburn() -> float:
	return _speed_afterburn


func get_acceleration() -> float:
	return _acceleration


func is_on_screen() -> bool:
	return _visible_notifier.is_on_screen()


func is_on_team(test_team: Team) -> bool:
	return team == test_team


func distance_to_ship(other_ship: Ship) -> float:
	return global_position.distance_to(other_ship.global_position)


func direction_to_ship(other_ship: Ship) -> Vector3:
	return global_position.direction_to(other_ship.global_position)


func current_velocity() -> Vector3:
	return _velocity_target


func get_roll_speed_max() -> float:
	return _roll_speed_max


func get_weapon_slot_positions() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for blaster_slot in _weapon_slots_blaster:
		result.append(blaster_slot.global_position)
	return result


func get_missile_launcher_position() -> Vector3:
	return _missile_launcher_slot.global_position


func get_current_blaster_speed() -> float:
	return _weapon_blaster.projectile_speed


func get_speed() -> float:
	return _velocity_target.length()


func get_speed_ratio() -> float:
	var speed_range: float = _speed_afterburn - _speed_base
	var speed_below_max: float = _speed_afterburn - get_speed()
	
	return 1 - (speed_below_max / speed_range)


func is_alive() -> bool:
	return _is_alive


func get_weapon_mode() -> WeaponMode:
	return _weapon_mode


func take_weapon_damage(damage: int) -> void:
	if not invulnerable:
		_health -= damage
		hull_health_chaged.emit(_health)
		if _health < 1:
			_die()


func get_detected_ships() -> Array[Ship]:
	return _detected_ships


func show_ship_mesh(show_ship: bool) -> void:
	_ship_mesh_inst.visible = show_ship


func has_active_shield() -> bool:
	if _shield:
		return _shield.is_active()
	else:
		return false


func get_missile_locked_ship() -> Ship:
	if is_instance_valid(_missile_lock_target):
		return _missile_lock_target
	return null


func get_hull_max_health() -> int:
	return _max_health


func get_shield_max_health() -> int:
	if _shield:
		return _shield.get_max_health()
	else:
		return -1


############################
# Signal Connected Methods #
############################
func _on_timer_fire_blaster_interval_timeout() -> void:
	if _controller.is_fire_commanded and _weapon_mode == WeaponMode.BLASTER:
		_fire_blaster()


func _on_timer_fire_missile_interval_timeout() -> void:
	if _controller.is_fire_commanded and _weapon_mode == WeaponMode.MISSILE:
		_fire_missile()


func _on_controller_change_weapon_mode_command(mode: Ship.WeaponMode) -> void:
	_weapon_mode = mode
	if _weapon_mode == WeaponMode.BLASTER:
		_missile_lock_target = null
		missile_lock_target_updated.emit(null)


func _on_controller_fire_weapon_command() -> void:
	if _weapon_mode == WeaponMode.BLASTER and _timer_fire_blaster_interval.is_stopped():
		_fire_blaster()
	elif _weapon_mode == WeaponMode.MISSILE and _timer_fire_missile_interval.is_stopped():
		_fire_missile()


func _on_ship_detection_area_body_entered(body: Node3D):
	var detected_ship: Ship =  body as Ship
	if detected_ship == self: 
		return
	
	if detected_ship.team != team:
		_detected_ships.append(detected_ship)
		detected_ship.destroyed.connect(_on_detected_ship_destroyed)


func _on_ship_detection_area_body_exited(body: Node3D):
	var detected_ship: Ship =  body as Ship
	if detected_ship.team != team:
		detected_ship.destroyed.disconnect(_on_detected_ship_destroyed)
		_detected_ships.erase(detected_ship)


func _on_detected_ship_destroyed(destroyed_ship: Ship) -> void:
	_detected_ships.erase(destroyed_ship)


func _on_shield_health_changed(value: int) -> void:
	shield_health_chaged.emit(value)


############################
#      Private Methods     #
############################
func _rpm_to_sbr(rpm: int) -> float: # rounds per minute to seconds between rounds
	return (1.0 / (rpm / 60.0))


func _fire_blaster() -> void:
	var direction: Vector3 = -basis.z
	if _controller is ShipControllerComputer:
		# Add spread to computer ship blaster bolts
		var spread: float = 5
		var deflection: float = deg_to_rad(spread * 0.5) * randf_range(-1.0, 1.0)
		direction = (-basis.z).rotated(
				basis.x, deflection
		)
		direction = direction.rotated(
				-basis.z, randf_range(0, TAU)
		)
	
	for slot_position in _weapon_slots_blaster:
		ProjectileManager.spawn_blaster_bolt(
				self, _weapon_blaster, slot_position.global_position, direction
		)
		
	_timer_fire_blaster_interval.start(_rpm_to_sbr(_weapon_blaster.rpm))
	_audio_primary_fire.pitch_scale = randf_range(0.80, 1.2)
	_audio_primary_fire.play()


func _fire_missile() -> void:
	if is_instance_valid(_missile_lock_target):
		ProjectileManager.spawn_missile(
				self, _weapon_missile, _missile_launcher_slot.global_position,
				-basis.z, _missile_lock_target
		)
	else:
		ProjectileManager.spawn_missile(
				self, _weapon_missile, _missile_launcher_slot.global_position,
				-basis.z, null
		)
	_timer_fire_missile_interval.start(_rpm_to_sbr(_weapon_missile.rpm))


func _update_missile_lock() -> void:
	var unlock_angle: float = deg_to_rad(10)
	if is_instance_valid(_missile_lock_target):
		if !_missile_lock_target.has_active_shield() and direction_to_ship(_missile_lock_target).angle_to(-basis.z) < unlock_angle:
			# Current target still has no shield and is within acceptable angle
			return
	
	var closest_angle: float = deg_to_rad(45) # max lock angle
	var closest_ship: Ship = null
	for ship in _detected_ships:
		# Check ship has no shield and is infront
		if !ship.has_active_shield() and direction_to_ship(ship).dot(-basis.z) > 0: 
			var ship_angle: float = direction_to_ship(ship).angle_to(-basis.z)
			if ship_angle < closest_angle:
				closest_angle = ship_angle
				closest_ship = ship
	
	if _missile_lock_target != closest_ship:
		_missile_lock_target = closest_ship
		missile_lock_target_updated.emit(closest_ship)


func _die() -> void:
	if _is_alive:
		_is_alive = false
		destroyed.emit(self)
		EffectSpawner.spawn_explosion_effect(global_position)
		call_deferred("queue_free")

