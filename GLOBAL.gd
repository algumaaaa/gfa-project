extends Node

var ammosum
var a
var m = 0
var p = 1
var d = 1
var r
var tick = null

var player = null
var spawner = null
var shortestDistance = null

var mouse_sensitivity = 0.05
var fov = 90

func _physics_process(delta):

	if Input.is_action_just_pressed("debug1"):
		_spawn_horde(1)
		print(shortestDistance)

	if player != null:
		ammosum = player.lactionammo + player.doublebammo + (player.nelevenammo * 0.5) + (player.mac10ammo * 0.5)
		if ammosum <= 10:
			a = 100
		elif ammosum >= 11 and ammosum <= 50:
			a = 60
		else:
			a = 20

		if player.damagequeue > 0:
			m += player.damagequeue

		r = ((a + m) * p) * d

	if spawner != null:
		if tick == null:
			tick = r
		if tick <= 0:
			tick = r
			if r >= 0 and r <= 33:
				_spawn_horde(5)
				m += 15
			elif r >= 34 and r <= 100:
				_spawn_horde(4)
			elif r >= 101 and r <= 150:
				_spawn_horde(3)
			else:
				_spawn_horde(2)

func _on_Timer_timeout():
	if m > 0:
		m -= 1
	if m < 0:
		m = 0
	if tick != null:
		tick -= 1

func _spawn_horde(value):
	var n = spawner.get_parent()
	for s in n.get_children():
		if s.enabled:
			var disto = s.global_transform.origin.distance_to(player.global_transform.origin)
			if shortestDistance == null:
				shortestDistance = s
			elif disto < shortestDistance.global_transform.origin.distance_to(player.global_transform.origin):
				shortestDistance = s
	print(shortestDistance)
	var w = shortestDistance.get_world().direct_space_state
	var r = w.intersect_ray(shortestDistance.global_transform.origin, player.global_transform.origin, [player])
	if r:
		shortestDistance._spawn_zombie(floor(value))
