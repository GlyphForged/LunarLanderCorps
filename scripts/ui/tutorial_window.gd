class_name Tutorial extends CanvasLayer

@export var confirm: Button

func _ready() -> void:
	confirm.pressed.connect(_tutorial_confirmed)

func _tutorial_confirmed():
	Signals.tutorial_confirmed.emit()
	get_parent().remove_child(self)
	self.queue_free()
