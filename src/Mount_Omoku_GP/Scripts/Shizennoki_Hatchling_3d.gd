extends CharacterBody3D

@onready var anim_player = $AnimationPlayer
@onready var camera = $Camera3D

var SPEED = 50.0
var FLOAT_APPROXIMATION: float = 0.0001	# see: func compare_floats


func start(pos):
	position = pos
	velocity = Vector3(0, 0, 0)


func _physics_process(delta):
	
	### TODO: Create Separate input lanes for Mouse/Joystick movement
	# TODO: Mouse: Get input direction
	
	# Joystick/WASD: Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(0, -input_dir.y, input_dir.x).normalized()
	
	if direction:
		velocity.z = direction.z * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
	
	### TODO: Replace with Animation Tree for animation transitions
	# Basic Animation Handling
	if direction == Vector3.ZERO && compare_floats(velocity.z, 0.0, FLOAT_APPROXIMATION) && compare_floats(velocity.y, 0.0, FLOAT_APPROXIMATION):	# not moving
		anim_player.pause()
	else:
		anim_player.play("Shizennoki_Hatchling/Shizennoki_Hatchling_Fly")

	move_and_slide()


## Compare two floats, returning true if their difference is within FLOAT_APPROXIMATION
func compare_floats(a, b, epsilon):
	return abs(a - b) <= epsilon

##================================================
## 	Custom look_at function that smooths rotation
##================================================
##   REF: https://www.reddit.com/r/godot/comments/e16krk/smooth_look_at_for_2d/
##	 Customized for 2.5D
##	
##   smooth_look_at for KinematicBody3D -> Call from _physics_process()
##   smooth_look_at for Node3D -> Call from _process()
##   
##   node = the node to turn
##   targetPos = the Vector3 (target.x, target.y, node.z) the node turns to face
##   turnSpeed = speed the node will turn to face the targetPos
##   
##   x+ is assumed to be the forward direction of the node
##================================================
func smooth_look_at(node, targetPos, turnSpeed):
	node.rotate(deg_to_rad(angular_look_at(node.global_position, node.global_rotation, targetPos, turnSpeed)))


# smooth_look_at supporting fn
func angular_look_at(currentPos, currentRot, targetPos, turnTime):
	return get_angle(currentRot, target_angle(currentPos, targetPos)) / turnTime


# smooth_look_at supporting fn
func get_angle(currentAngle, targetAngle):
	return fposmod(targetAngle - currentAngle + PI, PI * 2) - PI


# smooth_look_at supporting fn
func target_angle(currentPos, targetPos):
	return (targetPos - currentPos).angle()
