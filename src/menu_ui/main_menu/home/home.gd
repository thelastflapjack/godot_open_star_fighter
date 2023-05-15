extends MultiPageUIPage


func _on_btn_play_pressed(level_name: String) -> void:
	if active:
		SceneSwitcher.transition_to_level(level_name)


func _on_btn_settings_pressed() -> void:
	if active:
		change_page_request.emit("SettingsPage")


func _on_btn_controls_pressed() -> void:
	if active:
		change_page_request.emit("ControlsPage")


func _on_btn_credits_pressed() -> void:
	if active:
		change_page_request.emit("CreditsPage")


func _on_btn_quit_pressed() -> void:
	if active:
		get_tree().quit()
