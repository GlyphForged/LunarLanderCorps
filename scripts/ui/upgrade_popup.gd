extends CanvasLayer
class_name UpgradePopup

@export var mouse_mode_cache: Input.MouseMode
var lander: Lander
var upgrades: Dictionary = {
	"MaxFuel" = {
		friendly_name = "Max Fuel",
		cost = 50,
		upgradeAmt = 10.0,
	},
	"FuelEfficiency" = {
		friendly_name = "Fuel Efficiency",
		cost = 20,
		upgradeAmt = 0.1,
	},
	"MainThrust" = {
		friendly_name = "Main Thrust",
		cost = 30,
		upgradeAmt = 0.1,
	},
	"ControlThrust" = {
		friendly_name = "Control Thrust",
		cost = 15,
		upgradeAmt = 0.1,
	}
}

func _ready() -> void:
	self.mouse_mode_cache = Input.mouse_mode
	print(self.mouse_mode_cache)
	self.lander = get_tree().get_first_node_in_group("lander")
	%Exit.pressed.connect(_on_exit_pressed)

func _populate_list() -> void:
	for child in %UpgradeList:
		print(child)

func _on_exit_pressed() -> void:
	Input.mouse_mode = self.mouse_mode_cache
	get_tree().paused = false
	get_parent().remove_child(self)
	self.queue_free()
