extends OmniLight

var f = 40#rand_range(10, 20)

onready var timer = $Timer

func _ready():
	randomize()

func _on_Timer_timeout():
	if self.visible == false:
		f += rand_range(10, 100)
		self.visible = true
	if f > 0:
		f -= 1
	else:
		self.visible = false
	
