extends CharacterBody3D

const SPEED = 50.0
@onready var anim_player = $Blender/AnimationPlayer

func start(pos):
	position = pos
	velocity = Vector3(0, 0, 0)
	show()


func _physics_process(delta):
	
	### TODO: Create Separate input lanes for Mouse/Joystick movement
	# TODO: Mouse: Get input direction
	
	
	# Joystick: Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = Vector3(input_dir.x, -input_dir.y, 0).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		anim_player.play("Dragon_Squirming_Action")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
		anim_player.pause()

	move_and_slide()
	# print("Position:	", global_position)
