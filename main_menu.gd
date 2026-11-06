extends Control

@onready var start_button = $Start
@onready var quit_button = $Quit

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	print("Запуск игры...")
	get_tree().change_scene_to_file("res://LoadingScreen.tscn")

func _on_quit_pressed() -> void:
	print("Выход из игры...")
	get_tree().quit()
