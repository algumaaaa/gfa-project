extends KinematicBody

var path = []
var currentpathindex = 0
var navdir = Vector3()
var timerdelay = 0
var playerPos = Vector3()
var navstate = STOPPED
var targetrange = rand_range(10, 15)

onready var hitbox = $CollisionShape
onready var tick = $Timer
onready var nav = get_parent()
onready var bot = get_child(3)
onready var player = get_tree().get_root().get_node("/root/Spatial/player/")

enum {
	STOPPED,
	PATHING,
	HEALING
}

func _ready():
	randomize()

func _physics_process(delta):

	if bot == null:
		bot = get_child(3)
		return

	match navstate:

		STOPPED:
			currentpathindex = path.size()

		PATHING:
			if currentpathindex < path.size():
				navdir = path[currentpathindex]
				var direction = (path[currentpathindex] - global_transform.origin)
				if direction.length() < 1:
					currentpathindex += 1
				else:
					move_and_slide(direction.normalized() * bot.speed, Vector3.UP)

func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	currentpathindex = 0

func _on_Timer_timeout():

	if bot == null:
		return

	if bot.aiState == bot.AI.PATHING:
		playerPos = Vector3(player.global_transform.origin.x + get_random_pos_in_sphere(20).x + 5, player.global_transform.origin.y, player.global_transform.origin.z + get_random_pos_in_sphere(20).z + 5)
		get_target_path(playerPos)

	if bot.aiState == bot.AI.HEALING:
		get_target_path(bot.healTarget.global_transform.origin)

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
