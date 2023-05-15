class_name State
extends Node
# Virtual base class for all states.

### Signals ###
signal change_state_request(state_name: String, data: Dictionary)


# Virtual function. Corresponds to _unhandled_input() callback
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the _process() callback
func update(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the _physics_process() callback
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state.
func enter(_data: Dictionary = {}) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass

