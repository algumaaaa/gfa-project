extends Spatial

onready var animplay = $AnimationPlayer
var enTrig = false

func _ready():
	if enTrig:
		$AudioStreamPlayer3D.volume_db = -80
	animplay.play("drip")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
