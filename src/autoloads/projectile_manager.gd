extends Node
#class_name ProjectileManager


@onready
var _blaster_bolt_tscn: PackedScene = preload("res://src/projectiles/blaster_bolt.tscn")
@onready
var _missile_tscn: PackedScene = preload("res://src/projectiles/missile.tscn")


func spawn_blaster_bolt(source_parent: Node3D, source_blaster: Blaster, spawn_point: Vector3, direction: Vector3) -> void:
	var bolt: BlasterBolt = _blaster_bolt_tscn.instantiate()
	bolt.damage = source_blaster.projectile_damage
	bolt.velocity = direction.normalized() * source_blaster.projectile_speed
	bolt.max_range = source_blaster.max_range
	bolt.source = source_parent
	
	add_child(bolt)
	bolt.global_position = spawn_point
	bolt.look_at(spawn_point + direction, Vector3.UP)


func spawn_missile(source_parent: Node3D, launcher: MissileLauncher, spawn_point: Vector3, direction: Vector3, target: Node3D) -> void:
	var missile: Missile = _missile_tscn.instantiate()
	missile.target = target
	missile.turn_speed = launcher.turn_speed
	missile.speed = launcher.speed
	missile.max_time = launcher.max_time
	missile.source = source_parent
	missile.damage = launcher.damage
	
	add_child(missile)
	missile.global_position = spawn_point
	missile.direction = direction.normalized()
	missile.look_at(spawn_point + direction, Vector3.UP)
