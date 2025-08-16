extends HSlider


@onready var vol_label: Label = $vol_label

func _ready():
	# Connect the value_changed signal to the _on_value_changed method
	self.value_changed.connect(_on_value_changed)
	_on_value_changed(self.value)

func _on_value_changed(value):
	vol_label.text = str(int(value * 100))+"%"
