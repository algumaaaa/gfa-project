tool
extends Spatial

export var door = false
export var trapDoor = false
export var trapDoorWide = false

func _physics_process(delta):
	if door:
		$door.visible = true
		$doorShape.disabled = false
	else:
		$door.visible = false
		$doorShape.disabled = true
	if trapDoor:
		$trapDoor.visible = true
		$trapDoorShape.disabled = false
	else:
		$trapDoor.visible = false
		$trapDoorShape.disabled = true
	if trapDoorWide:
		$trapDoorWide.visible = true
		$trapDoorWideShape.disabled = false
	else:
		$trapDoorWide.visible = false
		$trapDoorWideShape.disabled = true
