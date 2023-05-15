extends LevelBase
class_name LevelHoops

var _hoops_total: int = 0
var _hoops_collected: int = 0
var _time: float


@onready var _label_time: Label = $CanvasLayer/VBoxContainer/LabelTime
@onready var _label_counter: Label = $CanvasLayer/VBoxContainer/LabelCounter
@onready var _summary_screen: Control = $CanvasLayer/SummaryScreen
@onready var _summary_label: Label = $CanvasLayer/SummaryScreen/Label


func _ready():
	super._ready()
	for child in get_children():
		if child is HoopPath:
			var path: HoopPath = (child as HoopPath)
			path.hoop_collected.connect(_on_hoop_path_hoop_collected)
			_hoops_total += path.get_hoop_count()
	
	_label_counter.text = "0 / %s" % _hoops_total
	
	var new_ship: Ship = _ship_tscn.instantiate()
	new_ship.setup(Ship.Team.BLUE, _ship_brain_player_tscn.instantiate())
	add_child(new_ship)
	set_player_ship(new_ship)
	
	_player_ship.destroyed.connect(_on_player_ship_destroyed)


func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		_time += delta
		_label_time.text = str(snapped(_time, 0.1))


func _on_hoop_path_hoop_collected() -> void:
	_hoops_collected += 1
	_label_counter.text = "%s / %s" % [_hoops_collected, _hoops_total]
	if _hoops_collected == _hoops_total:
		_level_complete()


func _on_player_ship_destroyed(_ship_ref: Ship) -> void:
	_summary_label.text = "Ship Crashed"
	_show_level_summary_screen()


func _on_summary_screen_exit_btn_pressed() -> void:
	get_tree().paused = false
	SceneSwitcher.transition_to_main_menu()


func _show_level_summary_screen() -> void:
	set_physics_process(false) # just to stop the stopwatch
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	get_tree().paused = true
	_summary_screen.show()


func _level_complete() -> void:
	_summary_label.text = "All Hoops Collected in %ss" % _label_time.text
	_show_level_summary_screen()


func _on_pause_menu_quit_level() -> void:
	_player_ship.destroyed.disconnect(_on_player_ship_destroyed)
	SceneSwitcher.transition_to_main_menu()


func _on_pause_menu_restart_level() -> void:
	_player_ship.destroyed.disconnect(_on_player_ship_destroyed)
	SceneSwitcher.transition_to_level(scene_file_path.get_file().split(".")[0])
