class_name PlaylistTitle extends CanvasLayer

@export var title: Label
@export var player: AnimationPlayer

func _ready() -> void:
	Signals.song_changed.connect(_show_song_title)

func _show_song_title(song_title: String) -> void:
	title.text = song_title
	get_tree().create_timer(0.5)
	player.play("slide-in")
