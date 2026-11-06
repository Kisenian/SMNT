extends Control

signal email_clicked(email_data: Dictionary)

@onready var title_label = $HBoxContainer/TitleLabel
@onready var from_label = $HBoxContainer/FromLabel

var current_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	current_data = data
	
	var title = data.get("title", "Нет темы")
	var from = data.get("from", "Неизвестно")
	var status = data.get("status", "read")
	
	if status == "new":
		title_label.text = "[NEW] " + title
		title_label.add_theme_color_override("font_color", Color.RED)
	else:
		title_label.text = title
		title_label.add_theme_color_override("font_color", Color.WHITE) 
		
	from_label.text = from

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			title_label.text = current_data.get("title", "Нет темы")
			title_label.remove_theme_color_override("font_color")
			
			current_data["status"] = "read" 
			email_clicked.emit(current_data)
			accept_event()
