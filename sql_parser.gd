extends Node

var database: Dictionary = {}

func load_database(db_file_path: String) -> bool:
	var file = FileAccess.open(db_file_path, FileAccess.READ)
	if file == null:
		print("ОШИБКА: Файл базы данных не найден по пути ", db_file_path)
		return false
		
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("ОШИБКА ПАРСИНГА JSON: ", json.get_error_message())
		return false
		
	database = json.data
	print("База данных загружена. Таблицы: ", database.keys())
	return true

func parse_sql_query(query_text: String) -> Dictionary:
	var result = {}
	var upper_text = query_text.to_upper()
	var clean_text = query_text.strip_edges()
	
	if not clean_text.to_upper().begins_with("SELECT"):
		return {"error": "Ты забыл SELECT! Ты ничего не получаешь на выходе."}
		
	var from_index = upper_text.find("FROM")
	if from_index == -1:
		return {"error": "У тебя нет FROM. Тебе же нужно откуда-то брать данные?"}
		
	var select_part = clean_text.substr(6, from_index - 6).strip_edges()
	var raw_cols = select_part.split(",")
	var parsed_select = []
	
	if select_part == "" or select_part == "*":
		parsed_select.append({"type": "ALL", "column": "*"})
	else:
		for col in raw_cols:
			col = col.strip_edges()
			var upper_col = col.to_upper()
			
			if upper_col.begins_with("SUM(") and upper_col.ends_with(")"):
				var inner = col.substr(4, col.length() - 5).strip_edges()
				parsed_select.append({"type": "SUM", "column": inner})
			elif upper_col.begins_with("AVG(") and upper_col.ends_with(")"):
				var inner = col.substr(4, col.length() - 5).strip_edges()
				parsed_select.append({"type": "AVG", "column": inner})
			else:
				parsed_select.append({"type": "COLUMN", "column": col})
				
	result["select_columns"] = parsed_select
	
	var where_index = upper_text.find("WHERE")
	var from_part = ""
	var where_part = ""
	
	if where_index != -1:
		from_part = clean_text.substr(from_index + 4, where_index - (from_index + 4)).strip_edges()
		where_part = clean_text.substr(where_index + 5).strip_edges()
	else:
		from_part = clean_text.substr(from_index + 4).strip_edges()
		
	result["from_table"] = from_part
	
	if where_part != "":
		var where_split = where_part.split("=")
		if where_split.size() == 2:
			result["where_column"] = where_split[0].strip_edges().to_lower()
			result["where_value"] = where_split[1].strip_edges().replace('"', '').replace("'", "")
		else:
			return {"error": "Неверный синтаксис в WHERE! Используй: WHERE column = value"}
	else:
		result["where_column"] = ""
		result["where_value"] = ""
		
	return result

func execute_query(parsed_query: Dictionary, tree: Tree) -> Dictionary:
	if parsed_query.has("error"):
		return {"error": parsed_query["error"]}
	
	var selected_cols = parsed_query["select_columns"]
	var target_table = parsed_query["from_table"].to_lower()
	var filter_col = parsed_query["where_column"]
	var filter_val = parsed_query["where_value"]
	
	# Проверка доступа через EventManager
	var allowed_table = EventManager.get_active_table()
	if target_table != allowed_table:
		return {"error": "Таблица '%s' заблокирована. Доступна только: %s" % [target_table, allowed_table]}
	
	var table_data: Array = database.get(target_table, [])
	if table_data.is_empty() and not database.has(target_table):
		return {"error": "Таблица '%s' не найдена в базе данных!" % target_table}
	
	# Фильтрация данных
	var filtered_records = []
	for record in table_data:
		var show_row = true
		if filter_col != "":
			var record_value = str(record.get(filter_col, "")).to_lower()
			if record_value != filter_val.to_lower():
				show_row = false
		if show_row:
			filtered_records.append(record)
	
	# Обработка SELECT
	var has_aggregates = false
	var aggregate_results = []
	var regular_cols = []
	
	for col_info in selected_cols:
		if col_info.type == "ALL":
			if table_data.size() > 0:
				for key in table_data[0].keys():
					regular_cols.append({"type": "COLUMN", "column": key})
			break
			
		if col_info.type == "SUM" or col_info.type == "AVG":
			has_aggregates = true
			var col_name = col_info.column
			var total = 0.0
			var count = 0
			
			for rec in filtered_records:
				var val = rec.get(col_name, 0)
				if val is int or val is float:
					total += float(val)
					count += 1
				else:
					return {"error": "Колонка '%s' содержит текст, нельзя посчитать!" % col_name}
			
			var result_value = 0.0
			var label = ""
			if col_info.type == "SUM":
				result_value = total
				label = "SUM(%s)" % col_name
			else:
				result_value = total / count if count > 0 else 0
				label = "AVG(%s)" % col_name
			
			aggregate_results.append({"label": label, "value": result_value})
			print("--- РЕЗУЛЬТАТ: %s = %s ---" % [label, result_value])
		else:
			regular_cols.append(col_info)
	
	# Возвращаем результаты для рендеринга
	return {
		"has_aggregates": has_aggregates,
		"aggregate_results": aggregate_results,
		"regular_cols": regular_cols,
		"filtered_records": filtered_records,
		"table_name": target_table
	}

func render_results(query_result: Dictionary, tree: Tree) -> void:
	if query_result.has("error"):
		print("SYNTAX ERROR: ", query_result["error"])
		tree.clear()
		return
	
	if query_result.has("has_aggregates") and query_result.has_aggregates:
		_render_aggregate_table(query_result.aggregate_results, tree)
	elif query_result.has("regular_cols") and query_result.regular_cols.size() > 0:
		_render_normal_table(query_result.regular_cols, query_result.filtered_records, tree)
	else:
		tree.clear()

func _render_aggregate_table(results: Array, tree: Tree) -> void:
	tree.columns = results.size()
	for i in range(results.size()):
		tree.set_column_title(i, results[i].label)
		tree.set_column_custom_minimum_width(i, 150)
	
	tree.clear()
	var root = tree.create_item()
	var item = tree.create_item(root)
	
	for i in range(results.size()):
		var value = results[i].value
		if value == floor(value):
			item.set_text(i, str(int(value)))
		else:
			item.set_text(i, "%.2f" % value)

func _render_normal_table(cols: Array, records: Array, tree: Tree) -> void:
	tree.columns = cols.size()
	for i in range(cols.size()):
		var col_key = cols[i].column
		var header_name = col_key
		tree.set_column_title(i, header_name)
		tree.set_column_custom_minimum_width(i, 100)
	
	tree.clear()
	var root = tree.create_item()
	
	for record in records:
		var item = tree.create_item(root)
		for i in range(cols.size()):
			var col_key = cols[i].column
			item.set_text(i, str(record.get(col_key, "NULL")))
