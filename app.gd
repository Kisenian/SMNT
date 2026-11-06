extends TextureRect

@export var app_name: String = ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var desktop = get_tree().get_first_node_in_group("desktop")
			desktop.open_app(app_name)
			accept_event()
