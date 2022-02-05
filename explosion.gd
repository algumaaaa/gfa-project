extends Spatial

var pos = self.global_transform.origin
onready var animplay = $AnimationPlayer
onready var area = $Area
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")

var exploded = false

func _ready():
	animplay.play("boom")
	exploded = true

func _physics_process(delta):
	if exploded:
		var bodies = area.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group("enemies"):
#				var space = get_world().direct_space_state
#				var collision = space.intersect_ray(global_transform.origin, b.global_transform.origin)
#				if collision.collider.is_in_group("enemies"):
				b.damagequeue += 150
				b.tookdamage = true
				exploded = false
	var distto = self.transform.origin.distance_to(player.transform.origin)
	if distto < 30:
		player.shootshake.play("shootheavy", range_lerp(15, distto, 0, 0, 1))

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
