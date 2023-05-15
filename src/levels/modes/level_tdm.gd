extends LevelBase
class_name LevelTdm


### Exported variables ###
@export var _team_size: int = 4

### Public variables ###

### Private variables ###
var _win_kill_count: int = 30
var _spawn_points: Array[Marker3D]
var _next_spawn_point_idx: int = 0
var _deaths_blue: int = 0 # If adding additional teams, use dictionary for death counters
var _deaths_red: int = 0

var _player_team: Ship.Team = Ship.Team.BLUE 

### Onready variables ###
@onready var _summary_screen: Control = $CanvasLayer/SummaryScreen
@onready var _spawn_timer_blue: Timer = $SpawnTimerBlue
@onready var _spawn_timer_red: Timer = $SpawnTimerRed

@onready var _deaths_progress_bar_blue: ProgressBar = $CanvasLayer/HBoxContainer/ProgressBarBlue
@onready var _deaths_progress_bar_red: ProgressBar = $CanvasLayer/HBoxContainer/ProgressBarRed
@onready var _winner_label: Label = $CanvasLayer/SummaryScreen/Label


############################
# Engine Callback Methods  #
############################
func _ready():
	super._ready()
	for child in $SpawnPoints.get_children():
		_spawn_points.append(child as Marker3D)
	
	_spawn_initial_ships()
	
	_deaths_progress_bar_blue.max_value = _win_kill_count
	_deaths_progress_bar_red.max_value = _win_kill_count


############################
# Signal Connected Methods #
############################
func _on_ship_destroyed(ship: Ship) -> void:
	if ship == _player_ship:
		_player_ship = null
	
	if ship.team == Ship.Team.BLUE:
		_deaths_blue += 1
		_deaths_progress_bar_blue.value = _win_kill_count - _deaths_blue
		if _spawn_timer_blue.is_stopped():
			_spawn_timer_blue.start()
	else:
		_deaths_red += 1
		_deaths_progress_bar_red.value = _win_kill_count - _deaths_red
		if _spawn_timer_red.is_stopped():
			_spawn_timer_red.start()
	
	#print("Blue: %s  |  Red:  %s" % [_deaths_red, _deaths_blue])
	
	if _win_kill_count == _deaths_red:
		# blue win
		_show_level_summary_screen()
	elif _win_kill_count == _deaths_blue:
		# red win
		_show_level_summary_screen()


func _on_spawn_timer_red_timeout() -> void:
	var count: int = ShipRegistry.team_count(Ship.Team.RED)
	if count < _team_size:
		_spawn_ship(Ship.Team.RED)
		if count + 1 != _team_size:
			_spawn_timer_red.start()


func _on_spawn_timer_blue_timeout() -> void:
	var count: int = ShipRegistry.team_count(Ship.Team.BLUE)
	if count < _team_size:
		_spawn_ship(Ship.Team.BLUE)
		if count + 1 != _team_size:
			_spawn_timer_blue.start()


func _on_summary_screen_exit_btn_pressed() -> void:
	get_tree().paused = false
	SceneSwitcher.transition_to_main_menu()



############################
#	  Private Methods	 #
############################
func _next_spawn_transform() -> Transform3D:
	var marker: Marker3D = _spawn_points[_next_spawn_point_idx]
	
	_next_spawn_point_idx += 1
	if _next_spawn_point_idx == _spawn_points.size():
		_next_spawn_point_idx = 0
	
	return marker.global_transform


func _spawn_ship(team: Ship.Team) -> void:
	var new_ship: Ship = _ship_tscn.instantiate()
	
	if _player_ship == null and team == _player_team:
		new_ship.setup(team, _ship_brain_player_tscn.instantiate())
		add_child(new_ship)
		set_player_ship(new_ship)
	else:
		new_ship.setup(team, _ship_brain_comp_tscn.instantiate())
		add_child(new_ship)
	
	new_ship.global_transform =  _next_spawn_transform()
	new_ship.destroyed.connect(_on_ship_destroyed)


func _spawn_initial_ships() -> void:
	for i in range(_team_size):
		for team in Ship.Team.values():
			_spawn_ship(int(team))


func _show_level_summary_screen() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	get_tree().paused = true
	
	if _deaths_blue < _deaths_red:
		_winner_label.text = "! Blue Wins !"
	else:
		_winner_label.text = "! Red Wins !"
	
	_summary_screen.show()

