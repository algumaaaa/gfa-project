extends Control

onready var GLOBAL = get_node("/root/GLOBAL/")

onready var popup = $Popup
onready var levelselect = $levelselect
onready var fovlabel = $Popup/MarginContainer/GridContainer/fovlabel
onready var sensitivitylabel = $Popup/MarginContainer/GridContainer/sensitivitylabel

onready var sensitivityslider = $Popup/MarginContainer/GridContainer/sensitivityslider
onready var fovSlider = $Popup/MarginContainer/GridContainer/fovslider
onready var displayButton = $Popup/MarginContainer/GridContainer/displayButton
onready var vsyncButton = $Popup/MarginContainer/GridContainer/vsyncButton

onready var nowLoading = $nowLoading

func _ready():
	get_tree().paused = false

	sensitivityslider.value = GLOBAL.mouse_sensitivity
	fovSlider.value = GLOBAL.fov
	displayButton.selected = GLOBAL.display
	vsyncButton.pressed = GLOBAL.vsync

func _on_start_pressed():
	if !levelselect.visible:
		levelselect.visible = true
	else:
		levelselect.visible = false

func _on_exit_pressed():
	get_tree().quit()

func _on_options_pressed():
	if !popup.visible:
		popup.visible = true
	else:
		popup.visible = false

func _on_e0m1_pressed():

	nowLoading.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://level.tscn")
#	GLOBAL._change_scene("res://level.tscn", get_tree().get_current_scene())

func _on_e1m1_pressed():

	nowLoading.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene("res://e1m1.scn")
#	GLOBAL._change_scene("res://e1m1.scn", get_tree().get_current_scene())

func _on_e0m2_pressed():
	get_tree().change_scene("res://e0m2.tscn")

func _on_sensitivityslider_value_changed(value):
	GLOBAL.mouse_sensitivity = value
	sensitivitylabel.text = str(stepify(value, 0.01))

func _on_fovslider_value_changed(value):
	GLOBAL.fov = value
	fovlabel.text = str(value)

func _on_displayButton_item_selected(index):
	GLOBAL.display = index

	if index == 0:
		OS.window_fullscreen = false
		OS.window_borderless = false
	if index == 1:
		OS.window_fullscreen = true
		OS.window_borderless = false
	if index == 2:
		OS.window_fullscreen = true
		OS.window_borderless = true

func _on_vsyncButton_toggled(button_pressed):

	GLOBAL.vsync = button_pressed
	OS.vsync_enabled = button_pressed
