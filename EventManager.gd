extends Node

signal event_changed(event_data: Dictionary, phase_data: Dictionary)
signal show_temporary_message(text: String, duration: float)
signal new_mail_arrived(new_mail_data: Dictionary)

var events = [
	{
		"id": 0,
		"name": "Утро первого дня",
		"phases": [
			{"type": "cutscene", "text": "ДЕНЬ 1"},
			
			{"type": "dialogue", "lines": [
				"Доброе утро! Я ваш помощник.",
				"Сегодня ваш первый рабочий день.",
                "Сейчас я покажу вам систему."
			]},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": "ВАЖНО: Новое задание", 
					"from": "Босс", 
					"content": "Привет, новичок! Как тебе на новом рабочем месте? 
					Посмотри ка сколько сейчас активных сотрудников, в последнее время совсем распоясались.",
					"status": "new",
					"has_reply": true,
					"correct_answer": "17",
					"valid_from_phase": 4
				  }
			},
			
			{"type": "dialogue", "lines": [
				"Вы прочитали письмо?",
				"Отлично! Это ваше первое задание.",
				"Таблица уже доступна в клиенте СУБД",
			]},
			
			{"type": "action", 
			 "window": "database",
			 "active_table": "employees",
			 "task": "Ваш менеджер хочет знать, сколько сейчас сотрудников на месте.
			Запомни основы языка SQL: сначала SELECT, потом FROM, далее WHERE, никак иначе.
			Попробуй получить все строчки (*) из таблицы employees, где status = 'active'
			и напиши количество сотрудников в ответе на письмо."},
			
			{"type": "dialogue", "lines": [
				"Молодец, стажёр!",
				"Это было первое задание.",
				"Ты же не думал, что это всё?"
			]},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": "Перерасчёт зарплаты", 
					"from": "Лиланд Кейн", 
					"content": "Новичок, можешь быстро посмотреть какая у меня ЗП стала, пожалуйста? Мне как бы понимать нужно смогу ли я позволить себе свободные траты... на пьянку с друзьями. Только не говори этим кадровым для чего я интересовался!! Может быть, тебя тоже с собой возьмём.",
					"status": "new",
					"has_reply": true,
					"correct_answer": "44000",
					"valid_from_phase": 9
				}
			},
			
			{"type": "dialogue", "lines": [
				"Ох, становится уже сложнее!",
				"Помнишь я говорила про WHERE? Если ты напишешь WHERE name = 'Лиланд Кейн', ты с лёгкостью найдёшь строчку с ней."
			]},
			
			{"type": "dialogue", "lines": [
				"Что такое? А, не переживай, я никому не расскажу о ваших планах. В конце концов, я искусственный интеллект!"
			]},
			
			{"type": "action", 
			 "window": "database",
			 "active_table": "employees",
			 "task": "Напоминаю: SELECT - FROM - WHERE. Лиланда Кейн."
			},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": "Тайский массаж", 
					"from": "Полуденные девы", 
					"content": "Устали от долгих смен в офисе? Не знаете чем себя занять в этот вечер? Приходите в 'Полуденные девы' к нашим прекрасным девочка. Мы согреем вашу ночь.",
					"status": "new",
					"has_reply": false,
				}
			},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": "Учёт объёма работ", 
					"from": "Виктор Барр", 
					"content": "Стажёр, требую вас проверить весь мой объём выполненной работы! Ваш прошлый коллега недосчитал мне ЧАС РАБОТЫ! Я уже не молодой, каждая копейка у меня на счету! Я не собираюсь, как вы, молодые, горбатиться за бесплатно!",
					"status": "new",
					"has_reply": true,
					"correct_answer": "232",
					"valid_from_phase": 12
				}
			},
			
			{"type": "action", 
			 "window": "database",
			 "active_table": "barr_04.xx",
			 "task": "SQL - интересный язык! Если хочешь получить сумму какого-то параметра, то после SELECT напиши SUM(параметр), и всё посчитается само! Да, буквально SELECT SUM(что-то)."
			},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": " ", 
					"from": "Виктор Барр", 
					"content": "Да вы издеваетесь что-ли?! Когда-нибудь уволюсь из вашей конторки к чёртовой матери!",
					"status": "new",
					"has_reply": false,
				}
			},
			
			{
				"type": "notification", 
				"text": "Новое письмо в папке 'Почта'",
				"new_mail": {
					"title": "Перевозка старого оборудования", 
					"from": "Роберт Монагер", 
					"content": "Нам срочно нужно посчитать, какой вес неисправного оборудования у нас в среднем.
					Поторопись, нам нужно знать, справятся ли наши грузовые машины.",
					"status": "new",
					"has_reply": true,
					"correct_answer": "62",
					"valid_from_phase": 15
				}
			},
			
			{"type": "action", 
			 "window": "database",
			 "active_table": "employees",
			 "task": "В среднем..? Чтобы посчитать среднее число просто используй AVG() вместо SUM(). Довольно легко, да?"
			},
			
			{"type": "dialogue-cutscene", 
			"lines": ["Вот оно как. 62 - средний вес человека в мире"]},
			
			{"type": "dialogue", 
			"lines": [
				"Вот оно как. 62 - средний вес оборудования в списке"
			]},
			
			{"type": "dialogue", "lines": [
				"Хорошая работа! На сегодня ты хорошо постарался."
			]},
		]
	}
]

var current_event_id: int = 0
var current_phase_id: int = 0

func _ready() -> void:
	pass

func start_event(event_id: int) -> void:
	if event_id < 0 or event_id >= events.size():
		print("Ивент не найден!")
		return
	
	current_event_id = event_id
	current_phase_id = 0
	
	print("=== НАЧАТ ИВЕНТ №", event_id, " ===")
	process_current_phase()

func process_current_phase() -> void:
	var event = events[current_event_id]
	var phase = event.phases[current_phase_id]
	
	print("Фаза ", current_phase_id, ": ", phase.type)
	
	event_changed.emit(event, phase)
	if phase.type == "notification":
		print("Это фаза notification. Проверяем наличие new_mail...")
		
		if phase.has("new_mail"):
			print("НАЙДЕНО ПОЛЕ new_mail! Отправляем сигнал...")
			print("Данные письма: ", phase.new_mail.title)
			new_mail_arrived.emit(phase.new_mail)
		else:
			print("Поля new_mail в этой фазе НЕТ. Сигнал не отправлен.")


func advance_phase() -> void:
	var event = events[current_event_id]
	if current_phase_id + 1 < event.phases.size():
		current_phase_id += 1
		print("Переход к фазе: ", event.phases[current_phase_id].type)
		process_current_phase()
	else:
		print("Все фазы текущего ивента завершены!")
		get_tree().change_scene_to_file("res://MainMenu.tscn")


func get_active_table() -> String:
	var current_event = events[current_event_id]
	var current_phase = current_event.phases[current_phase_id]
	return current_phase.get("active_table", "unknown")
