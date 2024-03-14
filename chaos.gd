extends Sprite2D

const MAX_COUNTER = 2
var counter = MAX_COUNTER
var grid_pos = 3.5

func _ready():
	$Counter.text = str(counter)

func reset():
	$GPUParticles2D1.restart()
	$GPUParticles2D2.restart()

func _process(_delta):
	position.x = lerp(position.x, float(64 * grid_pos), 0.5)

func count_down():
	counter -= 1
	if counter <= 0:
		grid_pos += 1
		counter = MAX_COUNTER
	$Counter.text = str(counter)

func set_grid_pos(new_pos):
	grid_pos = new_pos
	counter = MAX_COUNTER
	$Counter.text = str(counter)
