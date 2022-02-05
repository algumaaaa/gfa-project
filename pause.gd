extends Control

onready var popup = $pause/Popup
onready var pause = $pause

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause.visible:
			pause.visible = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
		else:
			pause.visible = false
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	

func _on_start_pressed():
	get_tree().change_scene("res://level.tscn")

func _on_exit_pressed():
	get_tree().quit()


func _on_options_pressed():
	if !popup.visible:
		popup.visible = true
	else:
		popup.visible = false
