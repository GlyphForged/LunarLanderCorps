class_name Tutorial extends Control

@export var confirm: Button

func _ready() -> void:
	confirm.pressed.connect(_tutorial_confirmed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	confirm.grab_focus()

func _tutorial_confirmed():
	Signals.tutorial_confirmed.emit()
	Signals.landed_on_target_pad.emit()
	get_parent().remove_child(self)
	self.queue_free()
