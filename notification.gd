extends Control

@onready var close = $Close

var advances_phase: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close.pressed.connect(notification_close)
	

func notification_close() -> void:
	if advances_phase:
		EventManager.advance_phase()
	queue_free()
