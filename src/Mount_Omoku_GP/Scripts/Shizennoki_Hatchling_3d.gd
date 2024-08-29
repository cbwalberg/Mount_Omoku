extends CharacterBody3D

# store refs for time efficiency
@onready var anim_player = $AnimationPlayer 
@onready var camera = $Camera3D

@export var rotation_step : float = 5
@export var SPEED = 50.0

var FLOAT_APPROXIMATION: float = 0.0001	# see: func compare_floats
var current_rotation : Quaternion
var target_rotation : Quaternion
var mouse_pos_3d : Vector3


func start(pos):
	position = pos
	velocity = Vector3(0, 0, 0)


# TODO (6/6): move Input handling to _unhandled_input(event)
func _physics_process(delta):
	
	### TODO (2/6): Create Separate input lanes for Mouse/Joystick movement
	# TODO: Mouse (3/6): Get input direction
	
	# Joystick/WASD: Get input direction
	# TODO (1/6): Test with joystick
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(0, -input_dir.y, input_dir.x).normalized()
	
	if direction:
		velocity.z = direction.z * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
	
	### TODO (5/6): Replace with Animation Tree for animation transitions
	# Basic Animation Handling
	if direction == Vector3.ZERO && compare_floats(velocity.z, 0.0, FLOAT_APPROXIMATION) && compare_floats(velocity.y, 0.0, FLOAT_APPROXIMATION):	# not moving
		anim_player.pause()
	else:
		anim_player.play("Shizennoki_Hatchling/Shizennoki_Hatchling_Fly")

	# TODO (4/6): Rotate player towards mouse
	
	move_and_slide()


## Compare two floats, returning true if their difference is within FLOAT_APPROXIMATION
func compare_floats(a, b, epsilon):
	return abs(a - b) <= epsilon
