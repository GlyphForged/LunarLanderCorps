class_name LoadingScreen extends CanvasLayer

var lines := [
	"reticulating splines...",
	"calibrating retro encabulator...",
	"bargaining with death...",
	"tuning the radio...",
	"contacting mission control..."
]
var i := 0

func _ready() -> void:
	var t:= Timer.new()
	t.one_shot = false
	t.wait_time = 1.5
	t.autostart = true
	t.process_mode = Node.PROCESS_MODE_ALWAYS
	self.add_child(t)
	t.timeout.connect(_on_tick)

func _on_tick() -> void:
	set_text(lines[i % lines.size()])
	i += 1

func _process(_delta):
	pass
	# if Input.is_action_just_pressed("pause"):
	# 	_on_resume_pressed()
func set_text(input):
	$PanelContainer2/MarginContainer/VBoxContainer/Label.text = input
