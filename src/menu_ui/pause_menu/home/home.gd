extends MultiPageUIPage
# Docstring

signal resume_requested()
signal restart_requested()
signal quit_requested()


func _unhandled_input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_cancel"):
			resume_requested.emit()


func _on_btn_resume_pressed() -> void:
	if active:
		resume_requested.emit()


func _on_btn_restart_pressed() -> void:
	if active:
		restart_requested.emit()


func _on_btn_settings_pressed() -> void:
	if active:
		change_page_request.emit("SettingsPage")


func _on_btn_controls_pressed() -> void:
	if active:
		change_page_request.emit("ControlsPage")


func _on_btn_quit_pressed() -> void:
	if active:
		quit_requested.emit()

