extends Control

@export var lander: Node3D
var lander_bod

func _ready():
	lander_bod = lander.get_child(0)

func hand_off():
	return lander_bod
