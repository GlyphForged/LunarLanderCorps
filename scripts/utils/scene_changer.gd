extends CanvasLayer

var new_scene_path: String
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_to(new_scene: Util.GAME_SCENES):
	match new_scene:
		Util.GAME_SCENES.GAME:
			new_scene_path = Util.GAME_ID
		Util.GAME_SCENES.MENU:
			new_scene_path = Util.MENU_ID

	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("Fade In Out")

func _new_scene():
	# This is called by the Animation Player at 0.5 sec
	get_tree().call_deferred("change_scene_to_file", new_scene_path)
