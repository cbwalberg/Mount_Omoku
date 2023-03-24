extends KinematicBody2D


export (float, 1, 10000) var horizontal_speed: float = 1250
export (float, 1, 10000) var vertical_speed: float = 950
export (float, 0, 1000) var amplitude: float = 50
export (float, 0, 6.283) var frequency: float = TAU
export (float, 0, 3.142) var phase: float = PI / 2	# phase constant 
export (float, 1, 100) var wavelength: float = TAU	# TAU = 2PI # = λ
export (float, 1, 100) var wavenumber: float = TAU / wavelength	# = k 


var time : float = 0
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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
# PHYSICS
func _physics_process(delta):
	process_input()
	move(delta)


# Receive and normalize player input
# Called by _physics_process
# TODO: Interruptions
func process_input():
	directional_input = Vector2.ZERO
	directional_input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	directional_input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	directional_input = directional_input.normalized()


# Called by _physics_process
func move(delta):
	##### FINDS VELOCITY #####
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
	##########################
	time += delta
	
	# harmonic wave along y axis (switch x and y), no offset
	if directional_input.angle() == Vector2.DOWN.angle() || directional_input.angle() == Vector2.UP.angle():
		velocity.x = - amplitude * frequency * cos(wavenumber * velocity.y - frequency * time + phase)
		velocity.y = directional_input.y * vertical_speed	# constant up/down speed
	else: # traiditonal harmonic wave along x axis, adding vertical offset
		velocity.x = directional_input.x * horizontal_speed	# constant forward/backward speed
		velocity.y = - amplitude * frequency * cos(wavenumber * velocity.x - frequency * time + phase) + (directional_input.y * vertical_speed)

	# Clockwise rotation beginning at 0 (or 2PI) radians, or 3 on a clock
	if directional_input == Vector2.ZERO:
		$AnimatedSprite.flip_v = false
		look_at(position + Vector2.RIGHT.rotated(Vector2(horizontal_speed, velocity.y).angle()))
	if (directional_input.x > 0 && directional_input.y > 0) || (directional_input.x > 0 && directional_input.y == 0):
		$AnimatedSprite.flip_v = false
		look_at(position + Vector2.RIGHT.rotated(velocity.angle()))
	if (directional_input.x < 0 && directional_input.y > 0)  || (directional_input.x == 0 && directional_input.y > 0):
		$AnimatedSprite.flip_v = true
		look_at(position + Vector2.DOWN.rotated((velocity.angle() - Vector2.DOWN.angle())))
	if (directional_input.x < 0 && directional_input.y < 0)  || (directional_input.x < 0 && directional_input.y == 0):
		$AnimatedSprite.flip_v = true
		look_at(position + Vector2.LEFT.rotated((velocity.angle() - Vector2.LEFT.angle())))
	if (directional_input.x > 0 && directional_input.y < 0)  || (directional_input.x == 0 && directional_input.y < 0) :
		$AnimatedSprite.flip_v = false
		look_at(position + Vector2.UP.rotated((velocity.angle() - Vector2.UP.angle())))

	# TODO: Accelerate up to top speed
	# TODO: Process collision
	# move_and_collide or move_and_slide?
	collision_results = move_and_collide(velocity * delta)
