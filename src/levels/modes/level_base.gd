extends Node3D
class_name LevelBase


var _player_ship: Ship

@warning_ignore("unused_private_class_variable")
var _ship_tscn: PackedScene = preload("res://src/ships/ships/ship_executioner.tscn")
var _ship_brain_comp_tscn: PackedScene = preload("res://src/ship_controllers/computer/ship_controller_computer.tscn")
var _ship_brain_player_tscn: PackedScene = preload("res://src/ship_controllers/player/player.tscn")

@onready var _game_camera_rig: GameCameraRig = $GameCameraRig
@onready var _pause_menu: PauseMenu = get_node_or_null("CanvasLayer/PauseMenu")


func _ready():
	_pause_menu.quit_level.connect(_on_pause_menu_quit_level)
	_pause_menu.restart_level.connect(_on_pause_menu_restart_level)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _pause_menu:
		_pause_menu.popup()


func set_player_ship(ship: Ship) -> void:
	_player_ship = ship
	_game_camera_rig.set_tracked_ship(_player_ship)
	var player_controller: PlayerController = _player_ship.get_node("PlayerController")
	player_controller.cam_rig = _game_camera_rig


func _on_pause_menu_quit_level() -> void:
	SceneSwitcher.transition_to_main_menu()


func _on_pause_menu_restart_level() -> void:
	SceneSwitcher.transition_to_level(scene_file_path.get_file().split(".")[0])

