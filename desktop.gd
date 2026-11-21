extends Control

@onready var apps = {
	"email": $MainWindow/EmailWindow,
	"db": $MainWindow/DbWindow,
	"inspector": $MainWindow/inspectorWindow,
	"image_viewer": $ImageViewer
}

@onready var DarkBack = $EvilBackground
@onready var assistant = $SMNTWindow
@onready var police = $PoliceWindow
@onready var timer_ui = $TimerUI # Убедись, что узел TimerUI есть в сцене Desktop!


var CutsceneScene = preload("res://days_intro.tscn")
var notification_scene = preload("res://notification_item.tscn")
var all_files_data: Array = []

var spam_timer: float = 0.0
var spam_interval: float = 10.0  # первое уведомление прилетит через 10 секунд

var spam_messages: Array = [
	"ВЫЙДИ",
	"ТЫ НИЧЕГО НЕ ДОКАЖЕШЬ",
	"МЫ УЖЕ ИДЁМ",
	"Посмотри в окно :>",
	"Одобрен кредит!"
]

func _ready() -> void:
	# 1. Сначала скрываем приложения
	close_all_apps()
	
	# 2. ПОДКЛЮЧАЕМ ВСЕ СИГНАЛЫ ДО ТОГО, КАК ЧТО-ТО НАЧНЁТСЯ
	EventManager.new_mail_arrived.connect(_on_new_mail)
	EventManager.event_changed.connect(_on_event_changed)
	
	if timer_ui:
		timer_ui.time_is_up.connect(_on_time_is_up)
		print("✅ Сигнал time_is_up подключен к таймеру.")
		
	if police and police.has_node("TalkWindow"):
		print("✅ Узел TalkWindow найден. Подключаем сигнал запуска таймера...")
		police.get_node("TalkWindow").interrogation_started.connect(_on_interrogation_started)
	
	# 3. Загружаем базу файлов
	var file = FileAccess.open("res://Files.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		all_files_data = json.data
		print("✅ База файлов загружена: ", all_files_data.size(), " файлов")
		
	# 4. И ТОЛЬКО ТЕПЕРЬ запускаем обработку текущей фазы!
	# Теперь все сигналы уже подключены и услышат emit()
	EventManager.process_current_phase()
	
	# 5. Применяем визуальные изменения для Дня 3
	if EventManager.current_event_id == 2:
		_activate_day_three_mode()

func open_app(app_name: String) -> void:
	if not apps.has(app_name):
		print("Нет приложения с именем: ", app_name)
		return
	var target = apps[app_name]
	var was_visible = target.visible
	
	close_all_apps()
	
	if not was_visible:
		target.show()
		print("Открыто: ", app_name)
	else:
		print("Закрыто: ", app_name)

func close_all_apps() -> void:
	for app in apps.values():
		app.hide()

func _on_new_mail(mail_data: Dictionary) -> void:
	print("Пришло новое письмо!")
	apps["email"].add_single_new_mail(mail_data)
	
func _on_event_changed(event_data: Dictionary, phase_data: Dictionary) -> void:
	if phase_data.type == "cutscene":
		print("Запуск полноэкранной катсцены...")
		
		var cutscene = CutsceneScene.instantiate()
		add_child(cutscene)
		cutscene.z_index = 1000

		var text_to_show = []
		if phase_data.has("lines"):
			text_to_show = phase_data.lines
		elif phase_data.has("text"):
			text_to_show = [phase_data.text]
		else:
			text_to_show = ["ДЕНЬ 1"]
		cutscene.play_cutscene(text_to_show)
	
	elif phase_data.type == "login":
		print("Запуск экрана входа в систему...")
		get_tree().change_scene_to_file("res://LoginScreen.tscn")
		
	elif phase_data.type == "notification":
		print("Показываем уведомление: ", phase_data.text)
		show_notification(phase_data.text)	
	
	elif phase_data.type == "help_cutscene":
		print("Запуск катсцены 'ПОМОГИ'...")
		var help_scene = preload("res://prototype_cutscene.tscn").instantiate()  # замени путь на свою сцену
		add_child(help_scene)
		help_scene.z_index = 1000


func show_notification(text: String, advances_phase: bool = true) -> void:
	if notification_scene == null:
		print("Сцена уведомления не найдена!")
		return
	
	var new_notification = notification_scene.instantiate()
	new_notification.advances_phase = advances_phase
	add_child(new_notification)
	new_notification.z_index = 1000
	
	var label = new_notification.get_node_or_null("Text")
	if label:
		label.text = text
	
	var screen_size = get_viewport_rect().size
	var notif_size = Vector2(320, 180)
	
	var margin = 50
	var max_x = screen_size.x - notif_size.x - margin
	var max_y = screen_size.y - notif_size.y - margin
	
	max_x = max(0, max_x)
	max_y = max(0, max_y)
	
	var random_x = randi_range(0, max_x)
	var random_y = randi_range(0, max_y)
	
	new_notification.position = Vector2(random_x, random_y)
	
	print("Уведомление создано в координатах: ", new_notification.position)


func open_image_viewer(file_path: String) -> void:
	# 1. Ищем данные файла в нашей загруженной базе
	var target_file_data = {}
	for f in all_files_data:
		if f.get("path") == file_path:
			target_file_data = f
			break
			
	if target_file_data.is_empty():
		print("⚠️ Ошибка: файл не найден в Files.json -> ", file_path)
		return

	# 2. Передаем полный словарь в вьювер
	# Проверь, как называется ключ в твоем словаре apps (image_viewer или file_viewer)
	var viewer_key = "image_viewer" 
	if not apps.has(viewer_key):
		viewer_key = "file_viewer" # если ты переименовала узел
		
	if apps.has(viewer_key):
		# Вызываем новую функцию show_file, которую мы добавили в вьювер
		apps[viewer_key].show_file(target_file_data)
	else:
		print("❌ ОШИБКА: Вьювер не найден в словаре apps!")

func _activate_day_three_mode() -> void:
	print("🚨 АКТИВАЦИЯ РЕЖИМА ДНЯ 3...")
	if assistant:
		assistant.hide()
	if DarkBack:
		DarkBack.show()
	if police:
		police.show();
		
		
func _on_interrogation_started() -> void:
	print("⏱️ ЗАПУСК ТАЙМЕРА!")
	timer_ui.start_timer()
	_switch_to_tense_music()

func _on_time_is_up() -> void:
	print("⏰ ВРЕМЯ ВЫШЛО!")
	timer_ui.stop_timer()
	# Вызываем проверку концовок из EventManager
	EventManager.check_endings()

func _process(delta: float) -> void:
	# Спамим ТОЛЬКО пока идёт таймер
	if timer_ui and timer_ui.is_active:
		spam_timer += delta
		if spam_timer >= spam_interval:
			spam_timer = 0.0
			# Следующее уведомление через случайное время — так живее и непредсказуемее
			spam_interval = randf_range(12.0, 25.0)
			show_notification(spam_messages[randi() % spam_messages.size()], false)

func _switch_to_tense_music() -> void:
	var player = $AudioStreamPlayer
	var tense_track = preload("res://music/tense_theme.mp3")  # замени на свой путь
	
	# Защита: если тревожная музыка уже играет (например, после возврата с экрана логина) — не переключаем повторно
	if player.stream == tense_track:
		return
	
	# Плавно глушим старую музыку...
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -40.0, 1.0)
	tween.tween_callback(func():
		player.stream = tense_track
		player.stream.loop = true 
		player.play()
		player.volume_db = -40.0
		create_tween().tween_property(player, "volume_db", 0.0, 2.0)
	)
