extends MultiPageUIManager
class_name PauseMenu
# Docstring

# CONSIDER: Make this an autoload?

signal quit_level()
signal restart_level()

@onready var _anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	super._ready()
	var home_page: MultiPageUIPage = _pages["Home"]
	home_page.resume_requested.connect(_on_resume_requested)
	home_page.restart_requested.connect(_on_restart_requested)
	home_page.quit_requested.connect(_on_quit_requested)


############################
#      Public Methods      #
############################
func popup() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().set_pause(true)
	_anim_player.play("popup")
	
	await _anim_player.animation_finished


############################
# Signal Connected Methods #
############################
func _on_resume_requested() -> void:
	#_disconnect_home_signals()
	_anim_player.play_backwards("popup")
	await _anim_player.animation_finished
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_visible(false)


func _on_restart_requested() -> void:
	#_disconnect_home_signals()
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	restart_level.emit()


func _on_quit_requested() -> void:
	#_disconnect_home_signals()
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	quit_level.emit()


############################
#      Private Methods     #
############################

func _connect_home_signals() -> void:
	var home_page: MultiPageUIPage = _pages["Home"]
	home_page.resume_requested.connect(_on_resume_requested)
	home_page.restart_requested.connect(_on_restart_requested)
	home_page.quit_requested.connect(_on_quit_requested)


func _disconnect_home_signals() -> void:
	var home_page: MultiPageUIPage = _pages["Home"]
	home_page.resume_requested.disconnect(_on_resume_requested)
	home_page.restart_requested.disconnect(_on_restart_requested)
	home_page.quit_requested.disconnect(_on_quit_requested)
