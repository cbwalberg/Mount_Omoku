extends KinematicBody2D


export (float, 1, 5000) var max_horizontal_speed: float = 1500
export (float, 1, 5000) var max_vertical_speed: float = max_horizontal_speed
export (float, 1, 5) var acceleration: float = 5
export (float, 1, 5) var rotation_step: float = 0.7
export (float, 0, 1000) var max_amplitude: float = 150
export (float, 0, 6.283) var frequency: float = TAU
export (float, 0, 3.142) var phase: float = PI / 2	# phase constant 
export (float, 1, 100) var wavelength: float = TAU	# TAU = 2PI # = λ
export (float, 1, 100) var wavenumber: float = TAU / wavelength	# = k 

var time : float = 0
var max_horizontal_velocity : float = 0
var max_vertical_velocity : float = 0
var velocity_y_offset: float = 0
var directional_input = Vector2()
var velocity = Vector2()
var collision_results: KinematicCollision2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func start(pos):
	position = pos
	$CollisionShape2D.disabled = false
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# NO PHYSICS
func _process(delta):
	process_input()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# PHYSICS
func _physics_process(delta):
	move(delta)


# Receive and normalize player input: WASD or Arrow Keys
# Called by _physics_process
# TODO: Interruptions
func process_input():
	directional_input = Vector2.ZERO
	if Input.is_action_pressed("right"):
		directional_input.x = 1
	if Input.is_action_pressed("left"):
		directional_input.x = -1
	if Input.is_action_pressed("down"):
		directional_input.y = 1
	if Input.is_action_pressed("up"):
		directional_input.y = -1
	directional_input = directional_input.normalized()


# Called by _physics_process
func move(delta):
	#==========================================================================================
	#	CALCULATE VELOCITY
	#==========================================================================================
	# 	DOCS for Harmonic Waves 
	# 	http://electron9.phys.utk.edu/optics421/modules/m1/mechwaves.htm, 
	# 	https://animations.physics.unsw.edu.au/jw/travelling_sine_wave.htm#phase
	# 	https://www.compadre.org/osp/EJSS/4470/255.htm (Advanced Questions)
	#
	# 	y(x,t) = A sin (k x - ω t + φ) 	(plus player input vertical shift)
	# 	y'(x, t) = -Aω cos (k x - ω t + φ)	(plus player input vertical shift)
	#
	# 	y = a length: the displacement (from origin) of the string the wave oscillates around
	# 	x = also a length: the position along the string
	# 	t = time, A = amplitude, k = wavenumber, ω = frequency, φ = phase constant
	#==========================================================================================
	time += delta
	
	# harmonic wave along y axis (switch x and y), no offset, when moving straight up or down
	if directional_input == Vector2.DOWN || directional_input == Vector2.UP:
		max_horizontal_velocity = -max_amplitude * frequency * cos(wavenumber * directional_input.y * max_vertical_speed - frequency * time + phase) # velocity x = x'(y, t)
		max_vertical_velocity = directional_input.y * max_vertical_speed
		
		velocity.x = lerp( # lerp = linear interpretation. used to accelerate from base to goal by rate
			velocity.x, # base
			max_horizontal_velocity, # goal
			acceleration * delta) # rate

		velocity.y = lerp(
			velocity.y, 
			max_vertical_velocity, 
			acceleration * delta)

	else:	# traditonal harmonic wave along x axis, adding vertical offset
		max_horizontal_velocity = directional_input.x * max_horizontal_speed
		max_vertical_velocity = -max_amplitude * frequency * cos(wavenumber * directional_input.x * max_horizontal_speed - frequency * time + phase) + velocity_y_offset # velocity y = y'(x, t)

		velocity.x = lerp(
			velocity.x,
			max_horizontal_velocity,
			acceleration * delta)

		velocity_y_offset = lerp(
			velocity_y_offset, 
			directional_input.y * max_vertical_speed, 
			acceleration * delta)

		velocity.y = lerp(
			velocity.y,
			max_vertical_velocity,
			acceleration * delta)

	#=============================
	#	ROTATE; smoothing WIP
	#=============================
	if directional_input == Vector2.ZERO: # NO INPUT
		if !$AnimatedSprite.flip_v: # If looking left
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(Vector2(max_horizontal_speed, velocity.y).angle()), rotation_step * delta)
		if $AnimatedSprite.flip_v: # If looking right
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(Vector2(-max_horizontal_speed, velocity.y).angle()), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y == 0: # RIGHT
		if velocity.x > 0: 
			$AnimatedSprite.flip_v = false
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(velocity.angle()), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y > 0: # DOWN RIGHT
		if velocity.x > 0: 
			$AnimatedSprite.flip_v = false
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(velocity.angle()), rotation_step * delta)	

	if directional_input.x == 0 && directional_input.y > 0: # DOWN
		smooth_look_at($".", global_position + Vector2.DOWN.rotated((velocity.angle() - Vector2.DOWN.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y > 0: # DOWN LEFT
		if velocity.x < 0: 
			$AnimatedSprite.flip_v = true
			smooth_look_at($".", global_position + Vector2.DOWN.rotated((velocity.angle() - Vector2.DOWN.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y == 0: # LEFT
		if velocity.x < 0: 
			$AnimatedSprite.flip_v = true
			smooth_look_at($".", global_position + Vector2.LEFT.rotated((velocity.angle() - Vector2.LEFT.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y < 0: # UP LEFT
		if velocity.x < 0: 
			$AnimatedSprite.flip_v = true
			smooth_look_at($".", global_position + Vector2.LEFT.rotated((velocity.angle() - Vector2.LEFT.angle())), rotation_step * delta)

	if directional_input.x == 0 && directional_input.y < 0: # UP
		smooth_look_at($".", global_position + Vector2.UP.rotated((velocity.angle() - Vector2.UP.angle())), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y < 0: # UP RIGHT
		if velocity.x > 0: 
			$AnimatedSprite.flip_v = false
			smooth_look_at($".", global_position + Vector2.UP.rotated((velocity.angle() - Vector2.UP.angle())), rotation_step * delta)

	# TODO: Process collision
	# move_and_collide or move_and_slide?
	collision_results = move_and_collide(velocity * delta)


#================================================
# 	Custom Look At function that smooths rotation
#================================================
#   REF: https://www.reddit.com/r/godot/comments/e16krk/smooth_look_at_for_2d/
#	
#   smooth_look_at for KinematicBody2D -> Call from _physics_process()
#   smooth_look_at for Node2D -> Call from _process()
#   
#   node = the node to turn
#   targetPos = the Vector2 the node turns to face
#   turnSpeed = speed the node will turn to face the targetPos
#   
#   X+ is assumed to be the forward direction of the node
#================================================
func smooth_look_at(node, targetPos, turnSpeed):
	node.rotate(
		deg2rad(
			angular_look_at(
				node.global_position, 
				node.global_rotation, 
				targetPos, 
				turnSpeed
			)
		)
	)


# Supporting functions for from smooth_look_at
func angular_look_at(currentPos, currentRot, targetPos, turnTime):
	return get_angle(currentRot, target_angle(currentPos, targetPos)) / turnTime


func get_angle(currentAngle, targetAngle):
	return fposmod(targetAngle - currentAngle + PI, PI * 2) - PI


func target_angle(currentPos, targetPos):
	return (targetPos - currentPos).angle()
