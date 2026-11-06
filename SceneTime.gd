extends Label

func _ready() -> void:
	update_clock()
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_clock)
	add_child(timer)

func update_clock() -> void:
	text = Time.get_time_string_from_system().left(5)
