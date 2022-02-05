extends Spatial

onready var animplay = $AnimationPlayer

func _ready():
	animplay.play("drip")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
