extends CharacterBody2D


# Direction & Rotation
@export var rotation_step : float = 0.6		# @export: variables exposed to engine editor for live testing
var directional_input : Vector2


# Linear Speed
@export var max_horizontal_linear_speed : int = 1250	# m/s
@export var max_vertical_linear_speed : int = 1250	# m/s
@export var linear_acceleration : float = 3.0	# m/s/s

var velocity_y_offset : float
var max_vertical_offset : float
var max_vertical_velocity : float
var max_horizontal_velocity : float

# Wave Speed
@export var max_amplitude : float = 75 	# A: wave height
@export var wavelength : float = 5.0 	# λ: how far the wave has traveled after one cycle
@export var frequency : float = 1 	# f: 1 / T ; cycles per second (TAU = 2π)

var angular_frequency : float = TAU * frequency		# ω: 2πf
var wavenumber : float = TAU / wavelength			# k: 2π/λ
var time : float = 0								# t: seconds since script began
var phase : float = 0								# φ: phase constant
var current_amplitude : float
var wave_acceleration : float


# Collision
var collision_results: KinematicCollision2D


# Supporting Functions
var FLOAT_APPROXIMATION: float = 0.01	# see: func compare_floats


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
	turn(delta)
	collide()


# Receive and normalize player input: WASD or Arrow Keys
# TODO: TEST USING MOUSE FOR DIRECTION INSTEAD OF WASD/ARROWS
# Called by _physics_process
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
	#	CALCULATE WAVE VELOCITY
	#=============================================================================================
	# 	DOCS for Harmonic Waves 
	# 	http://electron9.phys.utk.edu/optics421/modules/m1/mechwaves.htm, 
	# 	https://animations.physics.unsw.edu.au/jw/travelling_sine_wave.htm#phase
	# 	https://www.compadre.org/osp/EJSS/4470/255.htm (Advanced Questions)
	#
	# 	position:		y(x,t) 	 = A sin (k x - ω t + φ) since x is not a constant speed, we use max_velocity in its place
	# 	velocity:		y'(x, t) = -A ω cos (k x - ω t + φ)
	#	acceleration: 	y"(x, t) = -A ω ω sin (k x - ω t + φ)
	#
	# 	y = the displacement (from origin) of the string the wave oscillates around
	# 	x = the position along the string
	#	x' and y' = velocity of x and y respectively
	# 	t = time, A = amplitude, k = wavenumber, ω = angular_frequency, φ = phase constant, λ = wavelength
	#=============================================================================================
	time += delta
	
	# lerp = linear interpretation: used to accelerate from START to DESTINATION by WEIGHT (NOT suitable for wave acceleration)
	# https://www.reddit.com/r/godot/comments/lnqlnv/how_exactly_does_weight_work_in_lerp/
	
	# TODO: incorporate approximation
	# TODO: Account for acceleration AND decceleration
	# TODO: RESEARCH LERP ALTERNATIVES FOR WAVE ACCELERATION!! See damping example: https://godotengine.org/qa/137772/how-acceleration-and-deceleration-first-person-controller
	if directional_input == Vector2.ZERO && compare_floats(velocity.x, 0.0):	# not moving
		current_amplitude = max_amplitude / 2 # lerp(current_amplitude, max_amplitude / 2, linear_acceleration * delta)
		
		velocity.x = 0.0
		velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase)	# velocity y = y'(x, t)
		
		print("STILL:\t", velocity)
	elif directional_input == Vector2.ZERO && !compare_floats(velocity.x, 0.0):	# input stopped while moving: deccelerate
		current_amplitude = lerp(current_amplitude, max_amplitude / 2, linear_acceleration * delta)
		velocity_y_offset = lerp(velocity_y_offset, 0.0, linear_acceleration * delta)
		max_horizontal_velocity = directional_input.x * max_horizontal_linear_speed
		# wave_acceleration = -amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) # acceleration.y = y"(x, t)
		
		velocity.x = lerp(velocity.x, 0.0, linear_acceleration * delta)
		velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) + velocity_y_offset	# velocity y = y'(x, t)
		
		print("DECCELERATING:\t", velocity)
	else: 
		current_amplitude = lerp(current_amplitude, max_amplitude, linear_acceleration * delta)
		if directional_input == Vector2.DOWN || directional_input == Vector2.UP:	# when moving straight up or down we want the wave to move along the y axis (switch x and y) w/o offset 
			max_vertical_velocity = directional_input.y * max_vertical_linear_speed
			# wave_acceleration = -current_amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_vertical_velocity) - (angular_frequency * time) + phase) # acceleration.x = x"(y, t)
			
			velocity.x = -current_amplitude * angular_frequency * cos((wavenumber * max_vertical_velocity) - (angular_frequency * time) + phase)	# velocity.x = x'(y, t)
			velocity.y = lerp(velocity.y, max_vertical_velocity, linear_acceleration * delta)
			
			print("VERTICAL MOVEMENT:\t", velocity)
		else:	# traditonal harmonic wave movement along x axis, adding vertical offset
			# TODO: Ask Louie about how to calculate + incorporate velocity_y_offset
			max_vertical_offset = directional_input.y * max_vertical_linear_speed
			velocity_y_offset = lerp(velocity_y_offset, max_vertical_offset, linear_acceleration * delta)
			max_horizontal_velocity = directional_input.x * max_horizontal_linear_speed
			# wave_acceleration = -current_amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) # acceleration.y = y"(x, t)
			
			velocity.x = lerp(velocity.x, max_horizontal_velocity, linear_acceleration * delta)
			velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) + velocity_y_offset	# velocity y = y'(x, t)
				
			print("HORIZONTAL MOVEMENT:\t", velocity)

	# DEBUG #
	# print("Position:	", global_position)
	# print("Velocity:	", velocity)
	# print("Linear Acceleration Rate:	", linear_acceleration * delta)
	# print("Wave Acceleration Rate:	", wave_acceleration * delta)
	move_and_slide()


# Called by _physics_process
func turn(delta):
	#===================================================================
	#	ROTATE 
	#	TODO: Improve smoothing; reconsider smooth_look_at targetPos arg
	#===================================================================
	if directional_input == Vector2.ZERO: # NO INPUT
		if !$AnimatedSprite2D.flip_v: # If looking left
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(Vector2(max_horizontal_linear_speed, velocity.y).angle()), rotation_step * delta)
		if $AnimatedSprite2D.flip_v: # If looking right
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(Vector2(-max_horizontal_linear_speed, velocity.y).angle()), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y == 0: # RIGHT
		if velocity.x > 0: 
			$AnimatedSprite2D.flip_v = false
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(velocity.angle()), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y > 0: # DOWN RIGHT
		if velocity.x > 0: 
			$AnimatedSprite2D.flip_v = false
			smooth_look_at($".", global_position + Vector2.RIGHT.rotated(velocity.angle()), rotation_step * delta)	

	if directional_input.x == 0 && directional_input.y > 0: # DOWN
		smooth_look_at($".", global_position + Vector2.DOWN.rotated((velocity.angle() - Vector2.DOWN.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y > 0: # DOWN LEFT
		if velocity.x < 0: 
			$AnimatedSprite2D.flip_v = true
			smooth_look_at($".", global_position + Vector2.DOWN.rotated((velocity.angle() - Vector2.DOWN.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y == 0: # LEFT
		if velocity.x < 0: 
			$AnimatedSprite2D.flip_v = true
			smooth_look_at($".", global_position + Vector2.LEFT.rotated((velocity.angle() - Vector2.LEFT.angle())), rotation_step * delta)

	if directional_input.x < 0 && directional_input.y < 0: # UP LEFT
		if velocity.x < 0: 
			$AnimatedSprite2D.flip_v = true
			smooth_look_at($".", global_position + Vector2.LEFT.rotated((velocity.angle() - Vector2.LEFT.angle())), rotation_step * delta)

	if directional_input.x == 0 && directional_input.y < 0: # UP
		smooth_look_at($".", global_position + Vector2.UP.rotated((velocity.angle() - Vector2.UP.angle())), rotation_step * delta)

	if directional_input.x > 0 && directional_input.y < 0: # UP RIGHT
		if velocity.x > 0: 
			$AnimatedSprite2D.flip_v = false
			smooth_look_at($".", global_position + Vector2.UP.rotated((velocity.angle() - Vector2.UP.angle())), rotation_step * delta)


# TODO: Process collision
func collide():
	pass


# Compare two floats, returning true if their difference is within FLOAT_APPROXIMATION
func compare_floats(a, b, epsilon = FLOAT_APPROXIMATION):
	return abs(a - b) <= epsilon


# Determine if vectorA is within range of vectorB
func vector_in_range(vectorA: Vector2, vectorB: Vector2, range: Vector2):
	return compare_floats(vectorA.x, vectorB.x, range.x) && compare_floats(vectorA.y, vectorB.y, range.y)


#================================================
# 	Custom look_at function that smooths rotation
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
#   x+ is assumed to be the forward direction of the node
#================================================
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
