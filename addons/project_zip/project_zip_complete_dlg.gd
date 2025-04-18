@tool
extends Window


@onready var _location_label:Label = %ZipFileLocationLabel


func show_dialog(zip_file_path:String) -> void:
	_location_label.text = zip_file_path
	popup_centered()


func _on_close_requested():
	hide()


func _on_show_file_explorer_btn_pressed():
	var file_path := ProjectSettings.globalize_path(_location_label.text)
	OS.shell_show_in_file_manager(file_path, false)


func _on_ok_btn_pressed():
	hide()
