extends CharacterBody2D


# Direction & Rotation
@export var rotation_step : float = 5	# @export: variables exposed to engine editor for live testing
var direction_to_mouse: Vector2


# Linear Speed
@export var deccelerate_zone_radius: float = 1000		# TODO: BUILD IN BEACON
@export var max_horizontal_linear_speed : int = 1500	# m/s
@export var max_vertical_linear_speed : int = 1250	# m/s
@export var linear_acceleration : float = 3.0	# m/s/s

var current_vertical_offset_velocity : float
var target_vertical_offset_velocity : float
var target_vertical_velocity : float
var target_horizontal_velocity : float

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


# Switches
var idle_moving : bool = false # idle = false; moving = true


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
#	if Input.is_action_just_pressed("print_debug"):
#		print(global_position.distance_to(get_global_mouse_position())) #, "\n", get_global_mouse_position(), "\n\n")
	pass # process_input()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# PHYSICS
func _physics_process(delta):
	move(delta)
	turn(delta)
	collide()


# Called by _physics_process
# TODO: Implement Beacon
func turn(delta):
	if global_position.distance_to(get_global_mouse_position()) > deccelerate_zone_radius:
		direction_to_mouse = get_global_mouse_position() - global_position	# Get the direction
		
		# TODO: Improve smoothing of sprite flip
		if direction_to_mouse.x > 0.0: $AnimatedSprite2D.flip_v = false	# facing right
		else: $AnimatedSprite2D.flip_v = true	# facing left
		
		smooth_look_at($".", get_global_mouse_position() + Vector2(0.0, velocity.y), rotation_step * delta)
		$CollisionShape2D.rotation_degrees = get_rotation_degrees()


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
	
	# lerp = linear interpretation: used to accelerate from START to DESTINATION by WEIGHT
	# (NOT suitable for wave acceleration) as negative values change lerp funcitonality
	# https://www.reddit.com/r/godot/comments/lnqlnv/how_exactly_does_weight_work_in_lerp/
	
	# Mouse controls
	# Settle into the harmonic wave movement rhythm when moving generally towards mouse position
	# TODO: Use direct control of movement (no wave) when turning at an angle greater than the above threshold
	if global_position.distance_to(get_global_mouse_position()) > deccelerate_zone_radius:
		if $AnimatedSprite2D.flip_v: 
			target_horizontal_velocity = max_horizontal_linear_speed * -1
		else:
			target_horizontal_velocity = max_horizontal_linear_speed
		
		# TODO: If velocity and direction_to mouse position are within a cone, transition to wave movement. else, use direct movement
		target_vertical_offset_velocity = global_position.direction_to(get_global_mouse_position()).y * max_vertical_linear_speed
		current_vertical_offset_velocity = lerp(current_vertical_offset_velocity, target_vertical_offset_velocity, linear_acceleration * delta)
		# else:
			# current_vertical_offset_velocity = lerp(current_vertical_offset_velocity, 0.0, linear_acceleration * delta)

		velocity.x = lerp(velocity.x, target_horizontal_velocity, linear_acceleration * delta)
		velocity.y = -max_amplitude * angular_frequency * cos((wavenumber * max_horizontal_linear_speed) - (angular_frequency * time) + phase) + current_vertical_offset_velocity

	else: # idle: position within idle_radius of mouse_position idle
		velocity.x = lerp(velocity.x, 0.0, delta)
		velocity.y = -max_amplitude * angular_frequency * cos((wavenumber * max_horizontal_linear_speed) - (angular_frequency * time) + phase)
	
	# TODO: incorporate approximation
	# TODO: Account for acceleration AND decceleration
	# TODO: RESEARCH LERP ALTERNATIVES FOR WAVE ACCELERATION!! See damping example: https://godotengine.org/qa/137772/how-acceleration-and-deceleration-first-person-controller
#	if directional_input == Vector2.ZERO && compare_floats(velocity.x, 0.0, FLOAT_APPROXIMATION):	# not moving
#		current_amplitude = max_amplitude / 2 # lerp(current_amplitude, max_amplitude / 2, linear_acceleration * delta)
#
#		velocity.x = 0.0
#		velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase)	# velocity y = y'(x, t)
#
#		print("STILL:\t", velocity)
#	elif directional_input == Vector2.ZERO && !compare_floats(velocity.x, 0.0, FLOAT_APPROXIMATION):	# input stopped while moving: deccelerate
#		current_amplitude = lerp(current_amplitude, max_amplitude / 2, linear_acceleration * delta)
#		velocity_y_offset = lerp(velocity_y_offset, 0.0, linear_acceleration * delta)
#		max_horizontal_velocity = directional_input.x * max_horizontal_linear_speed
#		# wave_acceleration = -amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) # acceleration.y = y"(x, t)
#
#		velocity.x = lerp(velocity.x, 0.0, linear_acceleration * delta)
#		velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) + velocity_y_offset	# velocity y = y'(x, t)
#
#		print("DECCELERATING:\t", velocity)
#	else: 
#		current_amplitude = lerp(current_amplitude, max_amplitude, linear_acceleration * delta)
#		if directional_input == Vector2.DOWN || directional_input == Vector2.UP:	# when moving straight up or down we want the wave to move along the y axis (switch x and y) w/o offset 
#			max_vertical_velocity = directional_input.y * max_vertical_linear_speed
#			# wave_acceleration = -current_amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_vertical_velocity) - (angular_frequency * time) + phase) # acceleration.x = x"(y, t)
#
#			velocity.x = -current_amplitude * angular_frequency * cos((wavenumber * max_vertical_velocity) - (angular_frequency * time) + phase)	# velocity.x = x'(y, t)
#			velocity.y = lerp(velocity.y, max_vertical_velocity, linear_acceleration * delta)
#
#			print("VERTICAL MOVEMENT:\t", velocity)
#		else:	# traditonal harmonic wave movement along x axis, adding vertical offset
#			# TODO: Ask Louie about how to calculate + incorporate velocity_y_offset
#			max_vertical_offset = directional_input.y * max_vertical_linear_speed
#			velocity_y_offset = lerp(velocity_y_offset, max_vertical_offset, linear_acceleration * delta)
#			max_horizontal_velocity = directional_input.x * max_horizontal_linear_speed
#			# wave_acceleration = -current_amplitude * angular_frequency * angular_frequency * sin((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) # acceleration.y = y"(x, t)
#
#			velocity.x = lerp(velocity.x, max_horizontal_velocity, linear_acceleration * delta)
#			velocity.y = -current_amplitude * angular_frequency * cos((wavenumber * max_horizontal_velocity) - (angular_frequency * time) + phase) + velocity_y_offset	# velocity y = y'(x, t)
#
#			print("HORIZONTAL MOVEMENT:\t", velocity)

	# DEBUG #
	# print("Position:	", global_position)
	# print("Velocity:	", velocity)
	# print("Linear Acceleration Rate:	", linear_acceleration * delta)
	# print("Wave Acceleration Rate:	", wave_acceleration * delta)
	move_and_slide()


# TODO: Process collision
func collide():
	pass


# Compare two floats, returning true if their difference is within FLOAT_APPROXIMATION
func compare_floats(a, b, epsilon):
	return abs(a - b) <= epsilon


# Determine if vectorA is within an equivalence range of vectorB. ~= for Vector2s specifying an x and y range of equivalence
# Ex. vector_in_range(Vector2(30, 15), Vector2(25, 25), Vector2(5, 10)) returns true, because 30 is within 5 of 25 and 15 is within 10 of 25
func vector_in_range(vectorA: Vector2, vectorB: Vector2, equivalence_range: Vector2):
	return compare_floats(vectorA.x, vectorB.x, equivalence_range.x) && compare_floats(vectorA.y, vectorB.y, equivalence_range.y)


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
