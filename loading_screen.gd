extends Control # Или ColorRect, если у тебя он корневой

@onready var loading_text = $LoadingText 
@onready var loading_bar = $LoadingBar 

const TARGET_SCENE = "res://desktop.tscn"

func _ready() -> void:
	print("Начинаем загрузку Desktop...")
	show()
	ResourceLoader.load_threaded_request(TARGET_SCENE)
	await _wait_for_load()
	
	print("Загрузка завершена! Переходим на рабочий стол.")
	get_tree().change_scene_to_file(TARGET_SCENE)

func _wait_for_load() -> void:
	var status = ResourceLoader.load_threaded_get_status(TARGET_SCENE)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if loading_bar:
			var progress_array = []
			ResourceLoader.load_threaded_get_status(TARGET_SCENE, progress_array)
			loading_bar.value = progress_array[0] * 100
			
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(TARGET_SCENE)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		print("Сцена успешно загружена в память!")
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("❌ ОШИБКА: Не удалось загрузить сцену. Проверь путь: ", TARGET_SCENE)
