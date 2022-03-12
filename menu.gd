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

var epChosen = 1
var mapChosen = 1

var levelDict = {
	01: "res://level.tscn",
	02: "res://e0m2.tscn",
	11: "res://e1m1.scn",
	12: "res://e1m2.tscn"
}

func _ready():
	get_tree().paused = false

	sensitivityslider.value = GLOBAL.mouse_sensitivity
	fovSlider.value = GLOBAL.fov
	displayButton.selected = GLOBAL.display
	vsyncButton.pressed = GLOBAL.vsync


func _physics_process(delta):
	if Input.is_action_just_pressed("debug0"):
		print(levelDict[01])
	
	if !GLOBAL.bot1Enabled:
		$startMenu/VBoxBots/botName.editable = false
		$startMenu/VBoxBots/OptionButton.disabled = true
		$startMenu/VBoxBots/ColorPickerButton.disabled = true
	else:
		$startMenu/VBoxBots/botName.editable = true
		$startMenu/VBoxBots/OptionButton.disabled = false
		$startMenu/VBoxBots/ColorPickerButton.disabled = false
	if !GLOBAL.bot2Enabled:
		$startMenu/VBoxBots/botName2.editable = false
		$startMenu/VBoxBots/OptionButton2.disabled = true
		$startMenu/VBoxBots/ColorPickerButton2.disabled = true
	else:
		$startMenu/VBoxBots/botName2.editable = true
		$startMenu/VBoxBots/OptionButton2.disabled = false
		$startMenu/VBoxBots/ColorPickerButton2.disabled = false
	if !GLOBAL.bot3Enabled:
		$startMenu/VBoxBots/botName3.editable = false
		$startMenu/VBoxBots/OptionButton3.disabled = true
		$startMenu/VBoxBots/ColorPickerButton3.disabled = true
	else:
		$startMenu/VBoxBots/botName3.editable = true
		$startMenu/VBoxBots/OptionButton3.disabled = false
		$startMenu/VBoxBots/ColorPickerButton3.disabled = false

func _on_start_pressed():
#	if !levelselect.visible:
#		levelselect.visible = true
#	else:
#		levelselect.visible = false

	if !$startMenu.visible:
		$startMenu.visible = true
	else:
		$startMenu.visible = false

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

func _on_difficultyOptionButton_item_selected(index):
	GLOBAL.difficulty = index

func _on_enableBot_item_selected(index):
	if index == 1:
		GLOBAL.bot1Enabled = true
	else:
		GLOBAL.bot1Enabled = false

func _on_enableBot2_item_selected(index):
	if index == 1:
		GLOBAL.bot2Enabled = true
	else:
		GLOBAL.bot2Enabled = false

func _on_enableBot3_item_selected(index):
	if index == 1:
		GLOBAL.bot3Enabled = true
	else:
		GLOBAL.bot3Enabled = false

func _on_botName_text_changed(new_text):
	GLOBAL.bot1Name = new_text

func _on_botName2_text_changed(new_text):
	GLOBAL.bot2Name = new_text

func _on_botName3_text_changed(new_text):
	GLOBAL.bot3Name = new_text

func _on_OptionButton_item_selected(index):
	GLOBAL.bot1Aim = index

func _on_OptionButton2_item_selected(index):
	GLOBAL.bot2Aim = index

func _on_OptionButton3_item_selected(index):
	GLOBAL.bot3Aim = index

func _on_ColorPickerButton_color_changed(color):
	GLOBAL.bot1Color = color

func _on_ColorPickerButton2_color_changed(color):
	GLOBAL.bot2Color = color

func _on_ColorPickerButton3_color_changed(color):
	GLOBAL.bot3Color = color

func _on_episodeButton_item_selected(index):
	epChosen = index

func _on_mapButton_item_selected(index):
	mapChosen = index + 1

func _on_Button_pressed():
	nowLoading.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene(levelDict[int(String(epChosen) + String(mapChosen))])
