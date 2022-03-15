tool
extends Spatial
export var frame = 0
export var isWestWingKey = false
export var isPassageKey = false
export var isAltarKey = false

var HUD = null

onready var eventManagerChurch = get_tree().get_root().get_node("/root/Spatial/eventManagerChurch")

func _ready():
	$Sprite3D.frame = frame
	HUD = get_tree().get_root().get_node("/root/Spatial/Control/hud")

func _on_Area_body_entered(body):
	if frame != 2:
		return
	if body.is_in_group("player"):
		if isWestWingKey:
			eventManagerChurch.westWingKey = true
			HUD._textPopup("got key to the west altar room", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif isPassageKey:
			eventManagerChurch.passageKey = true
			HUD._textPopup("got key to the trapdoor", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif isAltarKey:
			eventManagerChurch.altarKey = true
			HUD._textPopup("got key to the passage behind altar", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		queue_free()
