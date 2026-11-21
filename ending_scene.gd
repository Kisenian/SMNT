extends Control

var can_skip: bool = false

@onready var hint_label = $HintLabel  # необязательно: Label с текстом "Кликни, чтобы вернуться в меню"

func _ready() -> void:
	# Небольшая пауза, чтобы случайный клик на старте не скипнул концовку мгновенно
	await get_tree().create_timer(1.5).timeout
	can_skip = true
	if hint_label:
		hint_label.show()

func _input(event: InputEvent) -> void:
	if not can_skip:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://MainMenu.tscn")
