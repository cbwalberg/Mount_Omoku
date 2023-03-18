extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	start($CameraStartPos.position)

func start(pos):
	position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
