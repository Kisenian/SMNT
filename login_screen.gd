extends ColorRect

@onready var password_input = $PasswordInput
@onready var status_label = $StatusLabel

var target_password = "UFGFIVrhSVIV"
var current_typed = ""
var login_success = false

func _ready() -> void:
	password_input.editable = false
	password_input.caret_blink = true 
	password_input.grab_focus()
	password_input.text = ""
	current_typed = ""
	status_label.hide()

func _input(event: InputEvent) -> void:
	if login_success:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if current_typed.length() < target_password.length():
			var next_char = target_password[current_typed.length()]
			current_typed += next_char
			password_input.text = current_typed
			
			# 💡 СОВЕТ: Если есть звук клавиш, раскомментируй строку ниже:
			# $KeyPressSound.play()
			
			if current_typed.length() == target_password.length():
				_on_login_success()

func _on_login_success() -> void:
	login_success = true
	password_input.release_focus()
	
	status_label.show()
	status_label.modulate = Color(0, 1, 0, 1) # Зелёный цвет
	await get_tree().create_timer(1.2).timeout
	EventManager.advance_phase()
	get_tree().change_scene_to_file("res://desktop.tscn")
