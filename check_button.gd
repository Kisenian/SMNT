extends Control

var notification_scene = preload("res://notification_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.event_changed.connect(_on_event_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_event_changed(event_data: Dictionary, phase_data: Dictionary) -> void:
	if phase_data.type == "notification":
		print("lol")
		add_notification(phase_data.text)

func add_notification(text: String) -> void:
	var new_notification = notification_scene.instantiate()
	self.add_child(new_notification)
	new_notification.z_index = 1000
	var label = new_notification.get_node("Text")
	label.text = text
	new_notification.force_update_transform()
	
	var screen_size = get_viewport_rect().size
	var notif_size = new_notification.size
	
	if notif_size.x < 10:
		notif_size = Vector2(320, 180)
		
	var margin = 50 
	var max_x = screen_size.x - notif_size.x - margin
	var max_y = screen_size.y - notif_size.y - margin
	
	max_x = max(0, max_x)
	max_y = max(0, max_y)
	
	var random_x = randi_range(0, max_x)
	var random_y = randi_range(0, max_y)
	
	new_notification.position = Vector2(random_x, random_y)
