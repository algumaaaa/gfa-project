extends KinematicBody

var path = []
var currentpathindex = 0
var navdir = Vector3()
var timerdelay = 0
var randompath = Vector3()
var navstate = IDLE

onready var hitbox = $CollisionShape
onready var tick = $Timer
onready var nav = get_parent()
onready var enemy = get_child(3)
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")

enum {
	STOPPED,
	IDLE,
	ALERT,
	PATHING
}

func _physics_process(delta):
	match navstate:

		STOPPED:
			currentpathindex = path.size()

		IDLE:
			enemy.ispathing = true
			if currentpathindex < path.size():
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * (enemy.speed * 0.15), Vector3.UP)

		ALERT:
			if currentpathindex < path.size():
				navdir = path[currentpathindex]
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * enemy.speed, Vector3.UP)

		PATHING:
			if currentpathindex < path.size():
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * enemy.speed, Vector3.UP)

func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, nav.get_closest_point(target_pos))
	currentpathindex = 0

func _on_Timer_timeout():
	if enemy == null:
		return
	timerdelay += 1
	var targetrange = rand_range(10, 15)
	if enemy.aistate == enemy.AI.IDLE and timerdelay > targetrange:
		timerdelay = 0
		if enemy.ispathing:
			randompath = Vector3(self.global_transform.origin.x + get_random_pos_in_sphere(20).x, 0, self.global_transform.origin.z + get_random_pos_in_sphere(20).z) + get_parent().global_transform.origin
			get_target_path(randompath)
			enemy.ispathing = false
	if enemy.aistate == enemy.AI.ALERT:
		get_target_path(player.global_transform.origin)
	if enemy.aistate == enemy.AI.PATHING:
		if enemy.ispathing:
			randompath = Vector3(player.global_transform.origin.x + get_random_pos_in_sphere(80).x,0,player.global_transform.origin.z + get_random_pos_in_sphere(80).z) + get_parent().global_transform.origin
			get_target_path(randompath)
			enemy.ispathing = false
	if !enemy.ispathing and enemy.aistate != enemy.AI.IDLE:
		enemy.aistate = enemy.AI.ALERT

func get_random_pos_in_sphere (radius : float) -> Vector3:
	var x1 = rand_range (-1, 1)
	var x2 = rand_range (-1, 1)

	while x1*x1 + x2*x2 >= 1:
		x1 = rand_range(-1, 1)
		x2 = rand_range(-1, 1)

	var random_pos_on_unit_sphere = Vector3 (
	2 * x1 * sqrt(1 - x1*x1 - x2*x2),
	2 * x2 * sqrt(1 - x1*x1 - x2*x2),
	1 - 2 * (x1*x1 + x2*x2))

	return random_pos_on_unit_sphere * rand_range (0, radius)
