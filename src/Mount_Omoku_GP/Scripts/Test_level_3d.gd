extends Node3D

@export var beacon_start_offset_2d: Vector2 = Vector2(25, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.start($PlayerStartPos.position)
	var beacon_start_offset_3d = Vector3($PlayerStartPos.position.x, beacon_start_offset_2d.y, beacon_start_offset_2d.x)
	$Light_Beacon.start($PlayerStartPos.position + beacon_start_offset_3d)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
