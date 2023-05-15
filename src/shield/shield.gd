@icon("res://node_icons/shieldcomb.svg")
extends StaticBody3D
class_name Shield


signal health_changed(value: int)

@export var _health_max: int = 100
@export var _recharge_delay: float = 5


var _damage_trauma_gain: float = 0.2
var _trauma: float = 0
var _trauma_recovery_rate: float = 0.6


@onready var _health: int = _health_max
@onready var _recharge_timer: Timer = $TimerRecharge
@onready var _mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _pop_particles: GPUParticles3D = $GPUParticles3D


func _ready() -> void:
	_recharge_timer.wait_time = _recharge_delay


func _physics_process(delta: float) -> void:
	if _trauma > 0:
		_trauma -= _trauma_recovery_rate * delta
	_mesh_inst.set_instance_shader_parameter("visibility", _trauma)


func is_active() -> bool:
	return _health > 0


func get_max_health() -> int:
	return _health_max


func take_weapon_damage(damage: int) -> void:
	_health -= damage
	_trauma += _damage_trauma_gain
	_trauma = clamp(_trauma, 0, 1)
	health_changed.emit(_health)
	if _health < 0:
		_mesh_inst.hide()
		_collision_shape.disabled = true
		_recharge_timer.start()
		_pop_particles.emitting = true


func _on_timer_recharge_timeout() -> void:
	_health = _health_max
	health_changed.emit(_health)
	_trauma = 1
	_mesh_inst.show()
	_collision_shape.disabled = false

