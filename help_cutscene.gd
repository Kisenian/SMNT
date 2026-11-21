extends ColorRect  # или Control, в зависимости от того, что у тебя корневой узел

@onready var anim_player1 = $HBoxContainer/VBoxContainer/AnimationPlayer  # поправь путь, если AnimationPlayer называется иначе
@onready var anim_player2 = $HBoxContainer/VBoxContainer2/AnimationPlayer
@onready var anim_player3 = $HBoxContainer/VBoxContainer3/AnimationPlayer

const PAUSE_BEFORE_START: float = 3.0
const DURATION: float = 1.0

func _ready() -> void:
	await get_tree().create_timer(PAUSE_BEFORE_START).timeout
	anim_player1.play("HELP")
	anim_player2.play("HELP")
	anim_player3.play("HELP")
	
	await get_tree().create_timer(DURATION).timeout

	hide()
	queue_free()
	EventManager.advance_phase()
