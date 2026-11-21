extends Control

@onready var start_button = $MenuButtons/Start
@onready var quit_button = $MenuButtons/Quit
@onready var load_button = $MenuButtons/Load
@onready var menu_buttons = $MenuButtons
@onready var save_slots = $SaveSlots

const PAUSE_DURATION: float = 8.0

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if load_button:
		load_button.pressed.connect(_on_load_pressed)
	_start_animation_loop()
	
	if has_node("SaveSlots/Slot1"):
		$SaveSlots/Slot1.pressed.connect(_on_slot_pressed.bind(1))
	if has_node("SaveSlots/Slot2"):
		$SaveSlots/Slot2.pressed.connect(_on_slot_pressed.bind(2))
	if has_node("SaveSlots/Slot3"):
		$SaveSlots/Slot3.pressed.connect(_on_slot_pressed.bind(3))
	if has_node("SaveSlots/BackButton"):
		$SaveSlots/BackButton.pressed.connect(_on_back_pressed)
	if save_slots:
		save_slots.hide()
		

func _start_animation_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(PAUSE_DURATION).timeout
		if not is_inside_tree():
			break
		if $AnimationPlayer and $AnimationPlayer.has_animation("MainMenuAni"):
			$AnimationPlayer.play("MainMenuAni")
			await $AnimationPlayer.animation_finished


func _exit_tree() -> void:
	if $AnimationPlayer:
		$AnimationPlayer.stop()

func _on_start_pressed() -> void:
	print("Запуск игры...")
	get_tree().change_scene_to_file("res://LoadingScreen.tscn")

func _on_quit_pressed() -> void:
	print("Выход из игры...")
	get_tree().quit()
	
func _on_load_pressed() -> void:
	print("Показываем слоты...")
	menu_buttons.hide()
	save_slots.show()

func _on_slot_pressed(day_number: int) -> void:
	print("Загружаем День ", day_number)
	EventManager.load_day(day_number)
	get_tree().change_scene_to_file("res://LoadingScreen.tscn")

func _on_back_pressed() -> void:
	print("Возврат в меню...")
	save_slots.hide()
	menu_buttons.show()
