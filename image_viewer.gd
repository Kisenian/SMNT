extends Control

@onready var image_display = $ImageDisplay  # TextureRect
@onready var text_display = $TextDisplay    # Label или RichTextLabel
@onready var send_button = $SendButton      # Кнопка "Отправить"
@onready var title_label = $TitleLabel      # Заголовок файла
@onready var close_button = $Close

var current_file_data: Dictionary = {}
var is_day_three: bool = false

func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	if close_button:
		close_button.pressed.connect(hide)
	hide()
	
	# Проверяем, День 3 ли сейчас
	if EventManager.current_event_id == 2:
		is_day_three = true
		send_button.show()
	else:
		send_button.hide()

func show_file(file_data: Dictionary) -> void:
	current_file_data = file_data
	title_label.text = file_data.get("title", "Без названия")
	
	var file_type = file_data.get("type", "image")
	var path = file_data.get("path", "")
	
	if file_type == "text":
		# Показываем текст
		image_display.hide()
		text_display.show()
		
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			text_display.text = file.get_as_text()
		else:
			text_display.text = "Ошибка: файл не найден"
	else:
		# Показываем картинку
		text_display.hide()
		image_display.show()
		
		var texture = load(path)
		if texture is Texture2D:
			image_display.texture = texture
		else:
			print("❌ Не удалось загрузить: ", path)
	
	show()
	print("📄 Открыт файл: ", file_data.get("title"))

func _on_send_pressed() -> void:
	if not is_day_three:
		return
	
	var weight = current_file_data.get("weight", 0)
	var clue_id = current_file_data.get("clue_id")
	
	# Отправляем сигнал в EventManager
	EventManager.submit_clue(weight, clue_id, current_file_data.get("title", ""))
	
	# Закрываем файл после отправки
	hide()
