extends CanvasLayer

@onready var label = $MessageLabel
@onready var animation_player = $AnimationPlayer
@onready var sound_player = $SoundPlayer

func show_message(message: String) -> void:
	label.text = message
	visible = true
	if message.contains("verloren"):
		animation_player.play("lost_screen")
	else:
		animation_player.play("show_end_screen")
	
	#sound_player.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name == "show_end_screen":
	hide() # Replace with function body.
