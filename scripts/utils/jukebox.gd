class_name Jukebox extends AudioStreamPlayer

var curr_track_idx = -1

func _ready() -> void:
	self.finished.connect(self._on_track_finished)
	_play_next_track()

func _play_next_track() -> void:
	curr_track_idx = (curr_track_idx + 1) % Util.PLAYLIST.size()
	var new_track_info = Util.PLAYLIST[curr_track_idx]
	var new_stream = load(new_track_info.path)
	self.stream = new_stream
	self.play()
	print("Playing %s" % new_track_info.title)
	Signals.song_changed.emit(new_track_info.title)

func _on_track_finished() -> void:
	_play_next_track()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("next-song"):
		print("Skip song pressed.")
		_play_next_track()
