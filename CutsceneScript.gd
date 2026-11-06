extends ColorRect

@onready var text_label = $Text
@onready var anim_player = $AnimationPlayer

func play_cutscene(lines: Array, duration_per_slide: float = 3.0) -> void:
	show()
	
	for line in lines:
		text_label.text = line
		await get_tree().create_timer(duration_per_slide).timeout
	
	if anim_player and anim_player.has_animation("FadeOut"):
		anim_player.play("FadeOut")
		await anim_player.animation_finished
		
	hide()
	queue_free()
	EventManager.advance_phase()
