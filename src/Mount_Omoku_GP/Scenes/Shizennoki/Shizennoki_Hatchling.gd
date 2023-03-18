extends KinematicBody2D


export (float, 1, 1000) var horizontal_speed: float = 10
export (float, 1, 500) var vertical_speed: float = 5
export (float, 1, 100) var wave: float = TAU # TAU  = PI * 2
export (float, 0, 1000) var amplitude: float = 5

var time : float = 0
var directional_input = Vector2()
var velocity = Vector2()


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
	
	# REF: Traditional up, down, left, right movement using constant speeds
	# velocity.x = directional_input.x * speed
	# velocity.y = directional_input.y * climb_speed
	# END REF
	
	# Transverse harmonic wave movement
	# DOCS: http://electron9.phys.utk.edu/optics421/modules/m1/mechwaves.htm, 
	# 		https://animations.physics.unsw.edu.au/jw/travelling_sine_wave.htm#phase
	#		https://www.compadre.org/osp/EJSS/4470/255.htm (Advanced Questions)

	# y(x,t) = A sin (k x - ω t + φ)		y = position.y
	# y'(x, t) = -Aω cos (k x - ω t + φ) 	y' = velocity.y
	
	# y = vertical position of coord on the wave (position.y)
	# x = horizontal position of coord on the wave (position.x) 
	# t = time
	# A = amplitude, k = wave = 2PI (assuming λ = 1), v = horizontal velocity, ω = k * v, t = delta, φ = vertical displacement (constant up/down speed)

	if directional_input.x != 0:
		# constant forward/backward speed
		velocity.x = directional_input.x * horizontal_speed
	else:
		velocity.x = 0

	if directional_input.y != 0:
		# y = amplitude * sin(wave * position.x - wave * velocity.x * time + directional_input.y * vertical_speed)
		velocity.y = -amplitude * wave * velocity.x * cos(wave * position.x - wave * velocity.x * delta + directional_input.y)
	else:
		velocity.y = 0

	velocity = move_and_slide(velocity)
	

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
