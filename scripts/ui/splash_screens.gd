extends Control

func _ready() -> void:
	%SplashAnimation.play("intro")

func _to_main_menu() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.MENU)
