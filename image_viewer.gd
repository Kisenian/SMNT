extends Control

@onready var image_display = $ImageDisplay
@onready var close_button = $Close

func _ready() -> void:
	close_button.pressed.connect(close_viewer)
	hide()

func show_image(file_path: String) -> void:
	var image = Image.new()
	var error = image.load(file_path)
	
	if error == OK:
		var texture = ImageTexture.create_from_image(image)
		image_display.texture = texture
		show()
		$AnimationPlayer.play("Opening")
		print("Изображение загружено: ", file_path)
	else:
		print("Ошибка загрузки изображения: ", file_path)

func close_viewer() -> void:
	hide()
	image_display.texture = null
