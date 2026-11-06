extends Control

@export var db_file_path: String = "res://database.json"

# Ссылки на UI
@onready var tree = $Tree
@onready var filter_input = $Input
@onready var refresh_button = $Refresh
@onready var table_name_label = $TableName

# Ссылка на парсер
var sql_parser: Node

func _ready() -> void:
	sql_parser = get_node_or_null("/root/SQLParser")
	if sql_parser == null:
		sql_parser = Node.new()
		sql_parser.set_script(load("res://sql_parser.gd"))
		get_tree().root.add_child(sql_parser)
		sql_parser.load_database(db_file_path)

	refresh_button.pressed.connect(_on_refresh_pressed)
	filter_input.text_submitted.connect(_on_refresh_pressed)  # Enter тоже выполняет запрос
	
	visibility_changed.connect(_on_visibility_changed)
	EventManager.event_changed.connect(_on_event_changed)

func _on_refresh_pressed() -> void:
	var raw_query = filter_input.text.strip_edges()
	
	if raw_query == "":
		var current_table = EventManager.get_active_table()
		raw_query = "SELECT * FROM " + current_table
		filter_input.text = raw_query
	
	var parsed = sql_parser.parse_sql_query(raw_query)
	
	if parsed.has("error"):
		EventManager.show_temporary_message.emit(parsed["error"], 3.0)
		return
	
	var result = sql_parser.execute_query(parsed, tree)
	sql_parser.render_results(result, tree)

func _on_visibility_changed() -> void:
	if visible:
		self.scale = Vector2(0, 0)
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Opening")
		
		var current_table = EventManager.get_active_table()
		if table_name_label and current_table != "unknown":
			table_name_label.text = current_table

func _on_event_changed(event_data: Dictionary, phase_data: Dictionary) -> void:
	if phase_data.type == "action":
		print("=== ПОЛУЧЕНО НОВОЕ ЗАДАНИЕ ===")
		print("Задание: ", phase_data.get("task", "Нет описания"))
		print("Активная таблица: ", phase_data.active_table)
		
		if table_name_label:
			table_name_label.text = phase_data.active_table

		var default_query = "SELECT * FROM " + phase_data.active_table
		filter_input.text = ""
		
		var parsed = sql_parser.parse_sql_query(default_query)
		var result = sql_parser.execute_query(parsed, tree)
		sql_parser.render_results(result, tree)
