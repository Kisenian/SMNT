extends Control

# Ссылки на окна, которые мы перетащили в сцену Desktop
@onready var email_app = $MainWindow/EmailWindow
@onready var db_app = $MainWindow/DbWindow

func _ready() -> void:
	EventManager.new_mail_arrived.connect(_on_new_mail)
	email_app.load_mails()
	db_app.load_database()

func open_app(app_name: String) -> void:
	email_app.hide()
	db_app.hide()
	
	if app_name == "email":
		email_app.show()
	elif app_name == "database":
		db_app.show()

func _on_new_mail(mail_data: Dictionary) -> void:
	print("Пришло новое письмо! Добавляем в EmailApp.")
	email_app.add_single_new_mail(mail_data)
