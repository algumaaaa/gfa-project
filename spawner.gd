extends Spatial

var spawnQueue = 0

export var enabled = true
export var event = false

onready var timer = $Timer

var navnode = preload("res://navnode.tscn")
var zombie = preload("res://enemy.tscn")
var worm = preload("res://worm.tscn")
var brawler = preload("res://brawler.tscn")
var spitter = preload("res://hitscanner.tscn")

func _ready():
	GLOBAL.spawner = self

func _on_button_toggled(value):
	if value == 1:
		_spawn_zombie(1)
	if value == 2:
		_spawn_worm(1)
	if value == 3:
		_spawn_spitter()
	if value == 4:
		_spawn_brawler(1)

func _spawn_zombie(value):
	if !enabled:
		return
	if value == 1:
		var n = navnode.instance()
		n.global_transform.origin = self.global_transform.origin - Vector3(0, 1.8, 0)
		get_parent().get_parent().add_child(n)
		var e = zombie.instance()
		e.transform.origin += Vector3(0, 2, 0)
		n.add_child(e)
		e.aistate = e.AI.ALERT
	else:
		spawnQueue = value
		timer.start()

func _spawn_worm(value):
	if !enabled:
		return
	while value != 0:
		value -= 1
		var w = worm.instance()
		w.global_transform.origin = self.global_transform.origin
		get_parent().get_parent().add_child(w)
		w.aistate = w.AI.ALERT

func _spawn_spitter():
	var s = spitter.instance()
	s.global_transform.origin = self.global_transform.origin
	get_parent().get_parent().add_child(s)
	s.aistate = s.AI.ALERT

func _spawn_brawler(value):
	if !enabled:
		return
	if value == 1:
		var n = navnode.instance()
		n.global_transform.origin = self.global_transform.origin - Vector3(0, 2.6, 0)
		get_parent().get_parent().add_child(n)
		var b = brawler.instance()
		b.transform.origin += Vector3(0, 2.8, 0)
		n.add_child(b)
		b.aistate = b.AI.ALERT

func _on_Timer_timeout():
	if spawnQueue > 0:
		var n = navnode.instance()
		n.global_transform.origin = self.global_transform.origin - Vector3(0, 1.8, 0)
		get_parent().get_parent().add_child(n)
		var e = zombie.instance()
		e.transform.origin += Vector3(0, 2, 0)
		n.add_child(e)
		e.aistate = e.AI.ALERT
		spawnQueue -= 1
		timer.start()

func _on_street_body_entered(body):
	if body.is_in_group("player"):
		enabled = false

func _on_doubleDoor_body_entered(body):
	if body.is_in_group("player"):
		enabled = false
