extends Spatial

export var enabled = true

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
		_spawn_brawler()

func _spawn_zombie(value):
	if !enabled:
		return
	while value != 0:
		value -= 1
		var e = zombie.instance()
		e.global_transform.origin = self.global_transform.origin
		get_parent().get_parent().add_child(e)
		e.aistate = e.AI.ALERT

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

func _spawn_brawler():
	var b = brawler.instance()
	b.global_transform.origin = self.global_transform.origin
	get_parent().get_parent().add_child(b)
	b.aistate = b.AI.ALERT
