class_name RemapButtonGroup

extends Control

@onready var key_label: Label = $HBoxContainer/KeyLabel
@onready var remap_key: Button = $HBoxContainer/RemapKey
@onready var remap_action: Button = $HBoxContainer/RemapAction

func _init(
	action_name: String,
	input_key: InputEventKey,
	input_action: InputEventAction
) -> void:
	key_label.text = action_name
	remap_key.text = input_key.as_text_key_label()
	remap_action.text = input_action.as_text()
