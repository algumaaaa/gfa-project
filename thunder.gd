extends Spatial


func _physics_process(delta):
	if Input.is_action_pressed("debug2"):
		self.visible = true
	else:
		self.visible = false
