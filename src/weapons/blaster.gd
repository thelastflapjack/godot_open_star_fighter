extends Resource
class_name Blaster

@export var projectile_damage: float
@export var projectile_speed: float
@export var rpm: int # rounds per minute
@export var max_range: int
@export var shoot_audio: AudioStream = preload("res://src/weapons/blaster_fire_ph.ogg")
