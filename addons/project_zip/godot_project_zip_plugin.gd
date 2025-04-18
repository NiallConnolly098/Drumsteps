@tool
extends EditorPlugin


const MENU_NAME = &"Zip Project"
const SKIP_DIRS = [
	"/.godot",
	"/.git"
]
const DLG_SCENE = preload("res://addons/project_zip/project_zip_complete_dlg.tscn")


var _dlg:Window


func _enter_tree():
	add_tool_menu_item(MENU_NAME, _zip_project)


func _exit_tree():
	remove_tool_menu_item(MENU_NAME)


func _zip_project() -> void:
	var proj_name := ProjectSettings.get_setting("application/config/name") as String
	var zip_file_path := "user://%s_%s.zip" % [proj_name.validate_filename(), _get_date_time_string()]
	var writer := ZIPPacker.new()
	if writer.open(zip_file_path) != OK:
		printerr("could not create zip file %s" % zip_file_path)
		return
	_zip_dir("", writer)
	writer.close()
	print("project files zipped to %s" % zip_file_path)
	if !_dlg:
		_dlg = DLG_SCENE.instantiate()
		add_child(_dlg)
	_dlg.show_dialog(zip_file_path)


func _zip_dir(dir_name: String, writer:ZIPPacker) -> void:
	if SKIP_DIRS.has(dir_name):
		return
	var dir := DirAccess.open("res://%s" % dir_name)
	if !dir:
		printerr("could not open project directory res://%s" % dir_name)
		return
	dir.include_hidden = true
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_file_path := "%s/%s" % [dir_name, file_name]
		if dir.current_is_dir():
			_zip_dir(full_file_path, writer)
		else:
			var file_contents := FileAccess.get_file_as_bytes("res://%s" % full_file_path)
			writer.start_file(full_file_path)
			writer.write_file(file_contents)
			writer.close_file()
		file_name = dir.get_next()


func _get_date_time_string() -> String:
	# year, month, day, weekday, dst (daylight savings time), hour, minute, second.
	var datetime = Time.get_datetime_dict_from_system()
	return "%d%02d%02d_%02d%02d%02d" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"]]
