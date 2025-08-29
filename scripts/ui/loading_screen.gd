extends CanvasLayer



func _ready() -> void:
	pass
	# Signals.settings_closed.connect(_on_settings_closed)
func _process(_delta):
	pass
	# if Input.is_action_just_pressed("pause"):
	# 	_on_resume_pressed()
func set_text(input):
	$PanelContainer2/MarginContainer/VBoxContainer/Label.text = input
