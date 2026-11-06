extends Control

@onready var apps = {
	"email": $MainWindow/EmailWindow,
	"db": $MainWindow/DbWindow,
	"inspector": $MainWindow/inspectorWindow,
	"image_viewer": $ImageViewer
}

var CutsceneScene = preload("res://days_intro.tscn")
var notification_scene = preload("res://notification_item.tscn")

func _ready() -> void:
	close_all_apps()
	EventManager.new_mail_arrived.connect(_on_new_mail)
	EventManager.event_changed.connect(_on_event_changed)
	EventManager.start_event(0)

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
		
	elif phase_data.type == "notification":
		print("Показываем уведомление: ", phase_data.text)
		show_notification(phase_data.text)	

func show_notification(text: String) -> void:
	if notification_scene == null:
		print("Сцена уведомления не найдена!")
		return
	
	var new_notification = notification_scene.instantiate()
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
	if apps.has("image_viewer"):
		apps["image_viewer"].show_image(file_path)
	else:
		print("ОШИБКА: image_viewer не найден в словаре apps!")
