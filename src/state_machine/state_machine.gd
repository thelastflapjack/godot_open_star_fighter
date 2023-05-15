class_name StateMachine
extends Node
# Generic state machine.

@export var _initial_state: State

var _current_state: State
var _states: Dictionary


############################
#      Public Methods      #
############################
func initalize() -> void:
	for child in get_children():
		if child is State:
			_states[child.name] = child
	
	transition_to(_initial_state.name)


# Corresponds to _unhandled_input() callback
func handle_input(event: InputEvent) -> void:
	_current_state.handle_input(event)


# Corresponds to the _process() callback
func update(delta: float) -> void:
	_current_state.update(delta)


# Corresponds to the _physics_process() callback
func physics_update(delta: float) -> void:
	_current_state.physics_update(delta)


func get_current_state() -> State:
	return _current_state


func transition_to(target_state_id: String, _data: Dictionary = {}) -> void:
	assert(_states.has(target_state_id), "Target state does not exist")
	if _current_state:
		_current_state.change_state_request.disconnect(_on_change_state_request)
		_current_state.exit()
	
	_current_state = _states[target_state_id]
	_current_state.change_state_request.connect(_on_change_state_request)
	_current_state.enter(_data)


############################
# Signal Connected Methods #
############################
func _on_change_state_request(state_id: String, data: Dictionary) -> void:
	transition_to(state_id, data)

