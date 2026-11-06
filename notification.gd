extends Control

@onready var close = $Close


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close.pressed.connect(notification_close)
	

func notification_close() -> void:
	queue_free()
	EventManager.advance_phase()
