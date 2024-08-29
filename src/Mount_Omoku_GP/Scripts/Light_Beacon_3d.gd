extends Node3D


@export var beacon_size: float = 25
@export var beacon_lerp_weight: float = 10.0		# multiplied by delta
@export var deccelerate_zone_radius: float = 1500


# Called when the node enters the scene tree for the first time.
# func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)	# TODO: change to MOUSE_MODE_CONFINED_HIDDEN after creating Pause scene


func start(pos):
	global_position = pos
	# $Size/CollisionShape3D.apply_scale(Vector2(beacon_size, beacon_size))
	# $Decceleration_zone/CollisionShape3D.apply_scale(Vector2(deccelerate_zone_radius, deccelerate_zone_radius))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("Beacon Position: ", global_position)
	pass


func _physics_process(delta):
	# TODO: FIX. get_viewport().get_mouse_position() not working as get_global_mouse_position() did to inform beacon position on screen
	var mouse_pos_3d = Vector3(global_position.x, get_viewport().get_mouse_position().y, get_viewport().get_mouse_position().x)
	global_position = global_position.lerp(mouse_pos_3d, beacon_lerp_weight * delta)
