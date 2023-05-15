class_name MultiPageUIPage
extends Control

signal change_page_request(page_name: String)

@export var cords: Vector2
@warning_ignore("unused_private_class_variable")
@export var _back_page_name: String

var active: bool = false


func _ready() -> void:
	cords = cords.snapped(Vector2(1,1))

