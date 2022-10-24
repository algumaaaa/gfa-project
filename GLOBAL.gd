extends Node

var ammosum
var a
var m = 0
var p = 1
var d = 1
var r
var tick = null

var bot1Enabled = false
var bot2Enabled = false
var bot3Enabled = false
var bot1Name = ""
var bot2Name = ""
var bot3Name = ""
var bot1Aim = 1
var bot2Aim = 1
var bot3Aim = 1
var bot1Color = Color(1, 1, 1, 1)
var bot2Color = Color(1, 1, 1, 1)
var bot3Color = Color(1, 1, 1, 1)
var bot1Health = 100
var bot2Health = 100
var bot3Health = 100
var bot1Ammo = 10
var bot2Ammo = 10
var bot3Ammo = 10
var bot1Deathcounter = 30
var bot2Deathcounter = 30
var bot3Deathcounter = 30

var player = null
var spawner = null
var shortestDistance = null

var difficulty
var mouse_sensitivity = 0.05
var fov = 90
var display = 0
var vsync = true
var soundVolume: float = 100.0


func _physics_process(delta):

	if get_tree().get_current_scene() != null and get_tree().get_current_scene().get_name() == "menu":
		return

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

		if difficulty == 0:
			d = 1
		elif difficulty == 1:
			d = 0.5

		r = ((a + m) * p) * d

#	if spawner != null:
#		if tick == null:
#			tick = r
#		if tick <= 0:
#			tick = r
#			if r >= 0 and r <= 33:
#				_spawn_horde(5)
#				m += 15
#			elif r >= 34 and r <= 100:
#				_spawn_horde(4)
#			elif r >= 101 and r <= 150:
#				_spawn_horde(3)
#			else:
#				_spawn_horde(2)


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
		if s.enabled and !s.event:
			var disto = s.global_transform.origin.distance_to(player.global_transform.origin)
			if shortestDistance == null:
				shortestDistance = s
			elif disto < shortestDistance.global_transform.origin.distance_to(player.global_transform.origin):
				shortestDistance = s
#	print(shortestDistance)
	if shortestDistance == null:
		return
	var w = shortestDistance.get_world().direct_space_state
	var r = w.intersect_ray(shortestDistance.global_transform.origin, player.global_transform.origin, [player])
	if r:
		shortestDistance._spawn_zombie(floor(value))


func _change_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)

	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			get_tree().get_root().call_deferred('add_child', resource.instance())
			current_scene.queue_free()
			break


func changeVolume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value - 100)
