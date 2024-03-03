extends Sprite2D

const MAX_COUNTER = 3
var counter = MAX_COUNTER
var grid_pos = 0

func _process(delta):
	position.x = lerp(position.x, float(64 * grid_pos), 0.5)

func count_down():
	counter -= 1
	if counter <= 0:
		grid_pos += 1
		counter = MAX_COUNTER
	$Counter.frame = counter-1

func set_grid_pos(new_pos):
	grid_pos = new_pos
	counter = MAX_COUNTER
	$Counter.frame = counter-1