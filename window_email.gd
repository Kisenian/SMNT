extends Control

var EmailItemScene = preload("res://email_item.tscn") 

@onready var mails_container = $VBoxContainer
@onready var content_label = $content_label
@onready var answer_input = $AnswerInput
@onready var send_button = $SendButton
@onready var close_button = $Close

var current_reply_mail: Dictionary = {}

func _ready() -> void:
	load_mails()
	
	if close_button:
		close_button.pressed.connect(close_window)
	if send_button:
		send_button.pressed.connect(_on_send_answer)
	if answer_input:
		answer_input.text_submitted.connect(_on_send_answer)
	
	# Прячем поле ввода при старте
	if answer_input:
		answer_input.hide()
	if send_button:
		send_button.hide()

func load_mails() -> void:
	var file_path = "res://Mails.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return
		
	var json_text = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		return
	
	var mails_array = json.data
	if mails_array == null or mails_array.size() == 0:
		return
	
	# Очищаем контейнер перед загрузкой
	for child in mails_container.get_children():
		child.queue_free()
	
	for mail_data in mails_array:
		var email_item = EmailItemScene.instantiate()
		mails_container.add_child(email_item)
		email_item.setup(mail_data)
		email_item.email_clicked.connect(show_email_content)

func show_email_content(data: Dictionary) -> void:
	print("Кликнули на письмо: ", data.get("title"))
	content_label.text = data.get("content", "Нет содержимого")
	
	if data.get("has_reply", false):
		print("На это письмо можно ответить!")
		current_reply_mail = data
		answer_input.text = ""
		answer_input.show()
		send_button.show()
		answer_input.grab_focus()
	else:
		answer_input.hide()
		send_button.hide()
		current_reply_mail = {}

func add_single_new_mail(mail_data: Dictionary) -> void:
	print("Окно почты получило новое письмо: ", mail_data.title)
	var email_item = EmailItemScene.instantiate()
	mails_container.add_child(email_item)
	email_item.setup(mail_data)
	email_item.email_clicked.connect(show_email_content)

func close_window() -> void:
	hide()

func _on_send_answer() -> void:
	if current_reply_mail.is_empty():
		return
	
	var player_answer = answer_input.text.strip_edges().to_lower()
	var correct_answer = current_reply_mail.get("correct_answer", "").strip_edges().to_lower()
	
	var valid_from = current_reply_mail.get("valid_from_phase", 0)
	if EventManager.current_phase_id < valid_from:
		print("Слишком рано! Текущая фаза: ", EventManager.current_phase_id, ", разрешено с: ", valid_from)
		EventManager.show_temporary_message.emit("Думал так можно, хитрец?", 2.5)
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Wrong")
		return
	
	if player_answer == correct_answer:
		print("ПРАВИЛЬНЫЙ ОТВЕТ! Переходим к следующей фазе.")
		current_reply_mail["has_reply"] = false 
		answer_input.hide()
		send_button.hide()
		EventManager.advance_phase()
	else:
		print("Неправильный ответ.")
		EventManager.show_temporary_message.emit("Неправильный ответ. Попробуй ещё раз.", 2.0)
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Wrong")
