extends MultiPageUIPage


func _on_btn_back_pressed() -> void:
	if active:
		change_page_request.emit(_back_page_name)
