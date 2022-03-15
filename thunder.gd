extends Spatial

var isNotVisible = true
var f = 3

func _physics_process(delta):
	
	if !isNotVisible:
		visible = true
		$thunderSound.play()
	else:
		visible = false

func _ready():
	randomize()
	yield(get_tree().create_timer(1.0), "timeout")
	$Timer.start()

func _on_Timer_timeout():
	if isNotVisible == false:
		f += rand_range(40, 60)
		isNotVisible = true
	if f > 0:
		f -= 1
	else:
		isNotVisible = false

func _on_rainSound_finished():
	$rainSound.play()
