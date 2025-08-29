class_name UpgradePopup
extends CanvasLayer

@export var mouse_mode_cache: Input.MouseMode
var lander: Lander
var upgrades: Dictionary = {
	"MaxFuelUpgrade" = {
		friendly_name = "Max Fuel",
		cost = 50,
		upgrade_amt = 10.0,
		upgrade_stat = "max_fuel",
	},
	"FuelEfficiencyUpgrade" = {
		friendly_name = "Fuel Efficiency",
		cost = 20,
		upgrade_amt = 0.1,
	},
	"MainThrustUpgrade" = {
		friendly_name = "Main Thrust",
		cost = 30,
		upgrade_amt = 0.1,
	},
	"ControlThrustUpgrade" = {
		friendly_name = "Control Thrust",
		cost = 15,
		upgrade_amt = 0.1,
	}
}

func _ready() -> void:
	%Exit.pressed.connect(_on_exit_pressed)
	self.mouse_mode_cache = Input.mouse_mode
	self.lander = get_tree().get_first_node_in_group("lander")
	_populate_list()
	get_tree().paused = true

func _populate_list() -> void:
	# A little bit psychotic, but allows for more dynamic upgrade list
	# New upgrades just need to be added to the dict, and then have their
	# HBox set to a unique name matching the upgrade key.
	%CurrentPts.text = ("%d PTS" % lander.current_pts)
	for child in %UpgradeList.get_children():
		if upgrades.has(child.name):
			# We know that each hboxcontainer will go:
			# Label, Button, Label:
			# UpgradeNameCost, Purchase, CurrentStat
			var f_name: String = upgrades[child.name].friendly_name
			var cost: int = upgrades[child.name].cost
			child.get_child(0).text = ("%s (%d pts)" % [f_name, cost])
			var btn: Button = child.get_child(1)
			# Avoid double connection
			if btn.pressed.is_connected(_on_purchase_pressed):
				btn.pressed.disconnect(_on_purchase_pressed)
			# Send the key with the button press.
			btn.pressed.connect(_on_purchase_pressed.bind(child.name))
			child.get_child(2).text = lander.get_stat(child.name)

func _on_purchase_pressed(upgrade_key: String) -> void:
	var upgrade = upgrade_key
	var cost: int = upgrades[upgrade].cost
	var amt: float = upgrades[upgrade].upgrade_amt
	lander.apply_upgrade(upgrade, cost, amt)
	_update_display()

func _update_display() -> void:
	lander = get_tree().get_first_node_in_group("lander")
	_populate_list()

func _on_exit_pressed() -> void:
	Input.mouse_mode = self.mouse_mode_cache
	get_tree().paused = false
	get_parent().remove_child(self)
	self.queue_free()
