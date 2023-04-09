extends Node2D


@export var debug_draw_length: int = 25 # length of draw_points array
@export var debug_draw_width: int = 100
var draw_points = [] # array containg snapshots of player position in time for debug drawing


# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.start($CameraStartPos.position)
	$Player.start($PlayerStartPos.position)
	$DrawTimer.start()
	draw_points.push_front($Player.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Called when DrawTimer hits 0
func _on_DrawTimer_timeout():
	force_update_transform() # force physics engine to update transform values for use in code
	draw_points.push_front($Player.global_position)
	if draw_points.size() > debug_draw_length: draw_points.pop_back()
	queue_redraw() # calls _draw()


# Draw on the canvas
func _draw():
	if draw_points.size() > 1: draw_polyline(draw_points, Color.CADET_BLUE, debug_draw_width) 
