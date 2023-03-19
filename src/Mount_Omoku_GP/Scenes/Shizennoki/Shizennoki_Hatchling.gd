extends KinematicBody2D


export (float, 1, 1000) var horizontal_speed: float = 50
export (float, 1, 500) var vertical_speed: float = 50
export (float, 0, 1000) var amplitude: float = 100
export (float, 0, 1000) var frequency: float = TAU
export (float, 1, 100) var wavelength: float = TAU * 5 # = 10PI
export (float, 1, 100) var wavenumber: float = TAU / wavelength # = k; TAU = 2PI


var time : float = 0
var directional_input = Vector2()
var velocity = Vector2()
var collision_results: KinematicCollision2D


# Called when the node enters the scene tree for the first time.
func _ready():
	start($PlayerStartPos.position)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
# NO PHYSICS
func _process(delta):
	directional_input = process_input()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# PHYSICS
func _physics_process(delta):
	time += delta

	# REF: Traditional up, down, left, right movement using constant speeds
	# velocity.x = directional_input.x * horizontal_speed * delta
	# velocity.y = directional_input.y * vertical_speed * delta
	# END REF
	
	# Transverse harmonic wave movement
	# DOCS: http://electron9.phys.utk.edu/optics421/modules/m1/mechwaves.htm, 
	# 		https://animations.physics.unsw.edu.au/jw/travelling_sine_wave.htm#phase
	#		https://www.compadre.org/osp/EJSS/4470/255.htm (Advanced Questions)

	# y(x,t) = A sin (k x - ω t) + vertical shift
	# y'(x, t) = -Aω cos (k x - ω t) + vertical shift
	
	# y = a length: the displacement (from origin) of the string the wave oscillates around
	# x = also a length: the position along the string
	# t = time
	# y', x' = ???
	# A = amplitude, k = wavenumber, ω = frequency

	velocity.x = directional_input.x * horizontal_speed * delta		# constant forward/backward speed
	velocity.y = (-amplitude * frequency * cos(wavenumber * velocity.x - frequency * time) + (directional_input.y * vertical_speed)) * delta

	collision_results = move_and_collide(velocity)
	
	# if collision_results:
	# 	TODO: Process collision
	

# Receive and normalize player input
# TODO: Interruptions
func process_input():
	directional_input = Vector2()
	if Input.is_action_pressed("right"):
		directional_input.x += 1
	if Input.is_action_pressed("left"):
		directional_input.x -= 1
	if Input.is_action_pressed("down"):
		directional_input.y += 1
	if Input.is_action_pressed("up"):
		directional_input.y -= 1
	
	return directional_input.normalized()
