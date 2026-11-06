extends Control

var FileItemScene = preload("res://inspector_item.tscn") 

@onready var files_container = $BoxContainer

func _ready() -> void:
	load_files()

func load_files() -> void:
	var file_path = "res://Files.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return
		
	var json_text = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		return
	
	var files_array = json.data
	if files_array == null or files_array.size() == 0:
		return
	
	for file_data in files_array:
		var file_item = FileItemScene.instantiate()

		files_container.add_child(file_item)
		file_item.setup(file_data)

		file_item.file_double_clicked.connect(_on_file_open_requested)

func _on_file_open_requested(file_path: String) -> void:
	print("Инспектор просит открыть файл: ", file_path)
	var desktop = get_tree().get_first_node_in_group("desktop")
	if desktop:
		desktop.open_image_viewer(file_path)
	else:
		print("ОШИБКА: Не найден узел Desktop в группе 'desktop'!")
