extends Node
# Manages loading of and transition between major scenes.


### Private variables ###
var _load_target_path: String
const _poll_time: float = 0.02
const _level_dir_path: String = "res://src/levels/"
const _main_menu_file_path: String = "res://src/menu_ui/main_menu/main_menu.tscn"

### Onready variables ###
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var _loader_poll_timer: Timer = $LoaderPollTimer
@onready var _progress_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_loader_poll_timer.wait_time = _poll_time


############################
#      Public Methods      #
############################
func transition_to_level(level_name: String) -> void:
	_change_scene_background("%s%s.tscn" % [_level_dir_path, level_name])


func transition_to_main_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_change_scene_background(_main_menu_file_path)


############################
# Signal Connected Methods #
############################
func _on_change_scene_request(scene_res_path: String) -> void:
	ShipRegistry.clear()
	call_deferred("_change_scene_background", scene_res_path)


func _on_loader_poll_timer_timeout() -> void:
	var load_progress: Array[float] = []
	var load_status: int = ResourceLoader.load_threaded_get_status(_load_target_path, load_progress)

	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene_res: PackedScene = ResourceLoader.load_threaded_get(_load_target_path)
		_set_current_scene(scene_res.instantiate())
	elif load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		#print(load_progress[0])
		_progress_bar.value = load_progress[0] # BUG: Will always be 0 https://github.com/godotengine/godot/issues/56882
		_loader_poll_timer.start()
	else:
		@warning_ignore("assert_always_false")
		assert(false, "ResourceInteractiveLoader Error: " + str(load_status))


############################
#      Private Methods     #
############################
func _fade_in() -> void:
	_progress_bar.hide()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_anim_player.play("fade_in")


func _fade_out() -> void:
	_progress_bar.hide()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_anim_player.play_backwards("fade_in")


func _set_current_scene(new_scene: Node) -> void:
	get_tree().get_root().add_child(new_scene)
	get_tree().current_scene = new_scene

	if _anim_player.is_playing():
		await _anim_player.animation_finished
	_fade_in()


func _change_scene_background(new_scene_path: String) -> void:
	_load_target_path = new_scene_path
	_fade_out()
	await _anim_player.animation_finished
	_progress_bar.value = 0
	_progress_bar.show()
	
	var current_scene: Node = get_tree().current_scene
	current_scene.queue_free()
	get_tree().current_scene = null
	
	ShipRegistry.clear()
	
	var err: int = ResourceLoader.load_threaded_request(_load_target_path, "PackedScene")
	assert(err == OK, "ResourceLoader.LoadThreadedRequest failed. Attemped load target path: " + _load_target_path)
	_loader_poll_timer.start()

