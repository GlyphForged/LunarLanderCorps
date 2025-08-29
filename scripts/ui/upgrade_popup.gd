class_name UpgradePopup
extends CanvasLayer

@export var mouse_mode_cache: Input.MouseMode
var lander: Lander
var upgrades: Dictionary = {
	"MaxFuelUpgrade" = {
		friendly_name = "Max Fuel",
		cost = 50,
		upgradeAmt = 10.0,
	},
	"FuelEfficiencyUpgrade" = {
		friendly_name = "Fuel Efficiency",
		cost = 20,
		upgradeAmt = 0.1,
	},
	"MainThrustUpgrade" = {
		friendly_name = "Main Thrust",
		cost = 30,
		upgradeAmt = 0.1,
	},
	"ControlThrustUpgrade" = {
		friendly_name = "Control Thrust",
		cost = 15,
		upgradeAmt = 0.1,
	}
}

func _ready() -> void:
	get_tree().paused = true
	self.mouse_mode_cache = Input.mouse_mode
	self.lander = get_tree().get_first_node_in_group("lander")
	%Exit.pressed.connect(_on_exit_pressed)
	_populate_list()

func _populate_list() -> void:
	for child in %UpgradeList.get_children():
		if upgrades.has(child.name):
			# We know that each hboxcontainer will go:
			# Label, Button, Label:
			# UpgradeNameCost, Purchase, CurrentStat
			var f_name: String = upgrades[child.name].friendly_name
			var cost: int = upgrades[child.name].cost
			var upgardeAmt: float = upgrades[child.name].upgradeAmt
			child.get_child(0).text = ("%s (%d pts)" % [f_name, cost])

func _on_exit_pressed() -> void:
	Input.mouse_mode = self.mouse_mode_cache
	get_tree().paused = false
	get_parent().remove_child(self)
	self.queue_free()
