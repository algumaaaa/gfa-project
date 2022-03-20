tool
extends Spatial
export var frame = 0
export var isWestWingKey = false
export var isPassageKey = false
export var isAltarKey = false

export var indexKey = 00

var HUD = null
var eventManager = null

func _ready():
	$Sprite3D.frame = frame
	HUD = get_tree().get_root().get_node("/root/Spatial/Control/hud")
	if get_tree().get_root().get_node_or_null("/root/Spatial/eventManagerChurch") != null:
		eventManager = get_tree().get_root().get_node("/root/Spatial/eventManagerChurch")
	elif get_tree().get_root().get_node_or_null("/root/Spatial/eventManagerBackstreets") != null:
		eventManager = get_tree().get_root().get_node("/root/Spatial/eventManagerBackstreets")

func _on_Area_body_entered(body):
	if frame != 2:
		return
	if body.is_in_group("player"):
		if isWestWingKey:
			eventManager.westWingKey = true
			HUD._textPopup("got key to the west altar room", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif isPassageKey:
			eventManager.passageKey = true
			HUD._textPopup("got key to the trapdoor", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif isAltarKey:
			eventManager.altarKey = true
			HUD._textPopup("got key to the passage behind altar", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true

		elif indexKey == 0:
			eventManager.key[0] = true
			HUD._textPopup("got key to the back alleys", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif indexKey == 1:
			eventManager.key[1] = true
			HUD._textPopup("got key to the dilapidated house", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif indexKey == 2:
			eventManager.key[2] = true
			HUD._textPopup("got key to the red house", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif indexKey == 3:
			eventManager.key[3] = true
			HUD._textPopup("got key to the underground shed", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		elif indexKey == 4:
			eventManager.key[4] = true
			HUD._textPopup("got key to the underground exit", 5)
			body.ammoAudio.play()
			body.ammoPickedUp = true
		queue_free()
