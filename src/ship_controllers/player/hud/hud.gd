extends Control
class_name Hud


var player_ship: Ship:
	set(value):
		player_ship = value
		_stat_bar_shield.max_value = player_ship.get_shield_max_health()
		_stat_bar_hull.max_value = player_ship.get_hull_max_health()
		
		_stat_bar_shield.value = _stat_bar_shield.max_value
		_stat_bar_hull.value = _stat_bar_hull.max_value
		
		player_ship.shield_health_chaged.connect(_on_ship_shield_health_changed)
		player_ship.hull_health_chaged.connect(_on_ship_hull_health_changed)
var cam: Camera3D
var solution_position: Vector3
var tracked_target: Node3D


var _target_markers: Array[TargetMarker]
var _off_screen_pointers: Array[Control]
var _tracked_target_marker: TargetMarker
var _lock_screen_radius: int = 200

@onready var _label_player_speed: Label = $LabelSpeed
@onready var _marker_target_lead: Control = $TargetLeadMarker
@onready var _lock_target_marker: Control = $LockMarker
@onready var _stat_bar_shield: ProgressBar = $StatBars/Shield
@onready var _stat_bar_hull: ProgressBar = $StatBars/Hull


func _ready() -> void:
	for child in $TargetMarkers.get_children():
		_target_markers.append(child as TargetMarker)
	
	for child in $OffScreenPointers.get_children():
		_off_screen_pointers.append(child as Control)


func _process(_delta: float) -> void:
	if player_ship.is_alive():
		_update_all_target_markers()
		var locked_target: Ship = player_ship.get_missile_locked_ship()
		if locked_target:
			_lock_target_marker.position = cam.unproject_position(locked_target.global_position)
			_lock_target_marker.visible = not locked_target.has_active_shield()
		else:
			_lock_target_marker.hide()


func _physics_process(_delta: float) -> void:
	if player_ship.is_alive():
		if tracked_target && is_instance_valid(tracked_target):
			_marker_target_lead.show()
			if _tracked_target_marker:
				_tracked_target_marker.update_range(round(player_ship.distance_to_ship(tracked_target)))
		else:
			_marker_target_lead.hide()
		
		_update_offscreen_pointers()
		_label_player_speed.text = str(snappedf(player_ship.get_speed(), 0.01))
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_ship.is_alive():
		if event.is_action_pressed("player_set_track"):
			_updatetracked_target()


func _draw() -> void:
	if tracked_target && _tracked_target_marker:
		draw_line(
				_tracked_target_marker.position, _marker_target_lead.position, 
				Color("ff6200"), 1, true
		)
	
	if player_ship.get_weapon_mode() == Ship.WeaponMode.MISSILE:
		# Draw dashed arc
		var dash_count := 10
		var dash_arc: float =  0.5 * (TAU / float(dash_count))
		var arc_angle: float = 0
		while arc_angle < TAU:
			draw_arc(
					get_rect().size * 0.5, _lock_screen_radius, 
					arc_angle, arc_angle + dash_arc, 
					4, Color(1,0,0, 0.5), 4, true
			)
			arc_angle += 2 * dash_arc


func update_intercept_marker_position(world_pos: Vector3) -> void:
	if not cam.is_position_behind(world_pos):
		_marker_target_lead.position = cam.unproject_position(world_pos)


func _on_ship_hull_health_changed(value: int) -> void:
	_stat_bar_hull.value = value


func _on_ship_shield_health_changed(value: int) -> void:
	_stat_bar_shield.value = value


func _update_all_target_markers() -> void:
	for i in range(_target_markers.size()):
		var marker: TargetMarker = _target_markers[i]
		marker.hide()
		marker.target = null
		marker.update_track(false)
		_tracked_target_marker = null
	
	var target_count: int = 0
	for target in ShipRegistry.all_ships():
		if target != self and target.is_on_screen() and target.team != player_ship.team:
			var marker: TargetMarker = _target_markers[target_count]
			marker.show()
			marker.position = cam.unproject_position(target.global_position)
			marker.target = target
			marker.show_shield_indicator(target.has_active_shield())
			if target == tracked_target:
				marker.update_track(true)
				_tracked_target_marker = marker
			
			target_count += 1
			if target_count == _target_markers.size(): 
				break


func _updatetracked_target() -> void:
	var mid_pos: Vector2 = get_rect().size * 0.5
	var closest_distance = mid_pos.x * 10
	var closest: TargetMarker
	for i in range(_target_markers.size()):
		var marker: TargetMarker = _target_markers[i]
		if marker.visible:
			marker.update_track(false)
			var dist: float = mid_pos.distance_to(marker.position)
			if dist < closest_distance:
				closest = marker
				closest_distance = dist
	
	if closest != null:
		closest.update_track(true)
		tracked_target = closest.target
		_tracked_target_marker = closest


func _update_offscreen_pointers() -> void:
	var detected_ships: Array[Ship] = player_ship.get_detected_ships()
	var detected_ship_idx: int = 0
	var pointer_idx: int = 0
	while pointer_idx < _off_screen_pointers.size():
		var pointer: Control = _off_screen_pointers[pointer_idx]
		if detected_ship_idx >= detected_ships.size():
			# No more ships, hide all remaining pointers
			pointer.hide()
			pointer_idx += 1
			continue
		
		var detected_ship: Ship = detected_ships[detected_ship_idx]
		if detected_ship.is_on_screen():
			detected_ship_idx += 1
			continue
		else:
			var target_dir: Vector3 = player_ship.direction_to_ship(detected_ship)
			var cross: Vector3 = player_ship.basis.y.cross(target_dir)
			var angle: float = atan2(cross.dot(-player_ship.basis.z), player_ship.basis.y.dot(target_dir))
		
			pointer.rotation = angle
			pointer.show()
			
			if detected_ship == tracked_target:
				pointer.modulate = Color.CORAL
			else:
				pointer.modulate = Color.WHITE
			
			detected_ship_idx += 1
			pointer_idx += 1

