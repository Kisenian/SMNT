extends Control

signal file_double_clicked(file_path: String)

@onready var icon = $Folder
@onready var title = $Name

var current_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	current_data = data
	title.text = data.get("title", "Неизвестно")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.double_click:
				var path = current_data.get("path", "")
				if path != "":
					print("Двойной клик! Открываем: ", path)
					file_double_clicked.emit(path)
				accept_event()
