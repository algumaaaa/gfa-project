tool
extends Spatial

export var door = false
export var doubleDoor = false
export var street = false
export var churchEvent = false

onready var doorArea = $door
onready var doubleDoorArea = $doubleDoor
onready var streetArea = $street
onready var churchEventArea = $churchEvent

func _process(delta):
	if !Engine.editor_hint:
		return

	if door:
		doorArea.monitoring = true
		doorArea.visible = true
	else:
		doorArea.monitoring = false
		doorArea.visible = false

	if doubleDoor:
		doubleDoorArea.monitoring = true
		doubleDoorArea.visible = true
	else:
		doubleDoorArea.monitoring = false
		doubleDoorArea.visible = false

	if street:
		streetArea.monitoring = true
		streetArea.visible = true
	else:
		streetArea.monitoring = false
		streetArea.visible = false

	if churchEvent:
		churchEventArea.monitoring = true
		churchEventArea.visible = true
	else:
		churchEventArea.monitoring = false
		churchEventArea.visible = false

func _ready():

	if door:
		doorArea.monitoring = true
		doorArea.visible = true
	else:
		doorArea.monitoring = false
		doorArea.visible = false

	if doubleDoor:
		doubleDoorArea.monitoring = true
		doubleDoorArea.visible = true
	else:
		doubleDoorArea.monitoring = false
		doubleDoorArea.visible = false

	if street:
		streetArea.monitoring = true
		streetArea.visible = true
	else:
		streetArea.monitoring = false
		streetArea.visible = false

	if churchEvent:
		churchEventArea.monitoring = true
		churchEventArea.visible = true
	else:
		churchEventArea.monitoring = false
		churchEventArea.visible = false
