extends Control

signal time_is_up

@onready var time_bar = $TimeBar

var max_time: float = 140.0
var time_left: float = 140.0
var is_active: bool = false

func start_timer() -> void:
	is_active = true
	time_left = max_time
	show()

func stop_timer() -> void:
	is_active = false
	hide()

func _process(delta: float) -> void:
	if not is_active:
		return
		
	time_left -= delta
	
	var percentage = (time_left / max_time) * 100.0
	time_bar.value = percentage
	
	if percentage < 20:
		time_bar.modulate = Color(1, 0, 0, 1)
		# Можно добавить мигание:
		time_bar.visible = int(Time.get_ticks_msec() / 200) % 2 == 0 
		
	if time_left <= 0:
		is_active = false
		time_is_up.emit() # Сигналим, что время вышло!
