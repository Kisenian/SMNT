extends Control

@onready var dialogue_text = $TextLabel
@onready var next_button = $Made
@onready var assistant_anim =  get_node_or_null("../SMNTWindow/AnimationPlayer")

var last_normal_text: String = ""
var is_showing_temporary: bool = false

func _ready() -> void:
	EventManager.event_changed.connect(_on_event_changed)
	next_button.pressed.connect(_on_next_pressed)
	EventManager.show_temporary_message.connect(_on_temporary_message)
	next_button.hide()
	hide()

func _on_event_changed(event_data: Dictionary, phase_data: Dictionary) -> void:
	if phase_data.type == "dialogue":
		show_dialogue(phase_data.lines)
	elif phase_data.type == "action":
		var task_text = phase_data.get("task", "Нет задания")
		show_dialogue([task_text])
		next_button.hide()
	elif phase_data.type == "dialogue-cutscene":
		show_cutscene(phase_data.lines)
	else:
		hide_dialogue()

func show_dialogue(lines: Array) -> void:
	var full_text = ""
	for line in lines:
		full_text += line + "\n\n"
		
	last_normal_text = full_text
	
	dialogue_text.text = full_text
	show()
	next_button.show()
	if assistant_anim and assistant_anim.has_animation("Talk"):
		assistant_anim.play("Talk")

func hide_dialogue() -> void:
	hide()
	next_button.hide()
	if assistant_anim:
		assistant_anim.stop()

func _on_next_pressed() -> void:
	hide_dialogue()
	EventManager.advance_phase()
	
func _on_temporary_message(text: String, duration: float) -> void:
	dialogue_text.text = text
	show()
	next_button.hide()
	is_showing_temporary = true
	
	await get_tree().create_timer(duration).timeout
	
	if last_normal_text != "":
		dialogue_text.text = last_normal_text
		next_button.show()
	else:
		hide_dialogue()
	
	is_showing_temporary = false

func show_cutscene(lines: Array) -> void:
	show()
	next_button.hide()
	for line in lines:
		dialogue_text.text = line
		await get_tree().create_timer(2.5).timeout
	hide_dialogue()
	EventManager.advance_phase()
