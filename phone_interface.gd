extends Control

@onready var detective_text = $TextLabel
@onready var phone_input = $Answer
@onready var send_button = $Send
@onready var next_button = $Next

signal interrogation_started

var lines: Array = []
var line_index: int = 0
var current_answer: String = ""
var phase_type: String = ""
var state: String = "idle"  # "paging" | "answer" | "idle"
var timer_started: bool = false
var showing_temporary: bool = false

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	send_button.pressed.connect(_on_send_pressed)
	phone_input.text_submitted.connect(_on_send_pressed)
	EventManager.event_changed.connect(_on_event_changed)
	EventManager.show_temporary_message.connect(_on_temporary_message)
	hide()

func _on_event_changed(event_data: Dictionary, phase_data: Dictionary) -> void:
	# Телефон живёт только в День 3
	if EventManager.current_event_id != 2:
		return
	
	if phase_data.type == "dialogue":
		_first_show()
		phase_type = "dialogue"
		_start_paging(phase_data.get("lines", []), "")
	elif phase_data.type == "action":
		_first_show()
		phase_type = "action"
		var task_lines = phase_data.get("lines", [phase_data.get("task", "")])
		var answer = phase_data.get("answer", "")
		_start_paging(task_lines, answer)
		if answer == "":
			# Начался свободный обыск — значит допрос пройден
			EventManager.interrogation_passed = true

func _first_show() -> void:
	show()
	if not timer_started:
		timer_started = true
		interrogation_started.emit()  # десктоп запустит таймер

func _start_paging(new_lines: Array, answer: String) -> void:
	lines = new_lines
	line_index = 0
	current_answer = answer
	state = "paging"
	phone_input.text = ""
	_refresh()

func _refresh() -> void:
	detective_text.text = "ДЕТЕКТИВ: " + lines[line_index]
	next_button.visible = (state == "paging")
	phone_input.visible = (state == "answer")
	send_button.visible = (state == "answer")
	if state == "answer":
		phone_input.grab_focus()

func _on_next_pressed() -> void:
	if state != "paging":
		return
	if line_index < lines.size() - 1:
		line_index += 1
		_refresh()
	else:
		# Последняя реплика фазы
		if current_answer != "":
			state = "answer"
			_refresh()
		elif phase_type == "dialogue":
			EventManager.advance_phase()
		else:
			# action без ответа = свободный обыск, ждём таймер и улики
			state = "idle"
			_refresh()

func _on_send_pressed() -> void:
	if state != "answer":
		return
	var answer = phone_input.text.strip_edges()
	if answer == "":
		return
	
	if answer.to_lower() == current_answer.to_lower():
		state = "idle"
		_refresh()
		detective_text.text = "ДЕТЕКТИВ: Принято. Записываю."
		await get_tree().create_timer(1.5).timeout
		EventManager.advance_phase()
	else:
		phone_input.text = ""
		_on_temporary_message("ДЕТЕКТИВ: Что-то здесь не так...", 2.0)

# Временные сообщения (реакции на улики) — как в диалоговом окне
func _on_temporary_message(text: String, duration: float) -> void:
	if EventManager.current_event_id != 2:
		return
	showing_temporary = true
	detective_text.text = text
	await get_tree().create_timer(duration).timeout
	showing_temporary = false
	_refresh()
