extends KinematicBody2D


export (float, 1, 10000) var horizontal_speed: float = 1250
export (float, 1, 10000) var vertical_speed: float = 1250
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
	directional_input = process_input()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# PHYSICS
func _physics_process(delta):
	time += delta
	
	# DOCS for Harmonic Waves: 
	# http://electron9.phys.utk.edu/optics421/modules/m1/mechwaves.htm, 
	# https://animations.physics.unsw.edu.au/jw/travelling_sine_wave.htm#phase
	# https://www.compadre.org/osp/EJSS/4470/255.htm (Advanced Questions)

	# y(x,t) = A sin (k x - ω t + φ) 	(plus player inputted vertical shift)
	# y'(x, t) = -Aω cos (k x - ω t + φ)	(plus player inputted vertical shift)
	
	# y = a length: the displacement (from origin) of the string the wave oscillates around
	# x = also a length: the position along the string
	# t = time
	# A = amplitude, k = wavenumber, ω = frequency, φ = phase constant
	velocity.x = directional_input.x * horizontal_speed	# constant forward/backward speed
	velocity.y = -amplitude * frequency * cos(wavenumber * velocity.x - frequency * time + phase) + (directional_input.y * vertical_speed)

	# TODO: change rotation to look at velocity vector
	if velocity.x != 0: $AnimatedSprite.rotation = lerp_angle(rotation,velocity.angle(),0.1)
	
	# TODO: Accelerate up to top speed

	# move_and_collide or move_and_slide?
	# TODO: Process collision
	collision_results = move_and_collide(velocity * delta)
	

# Receive and normalize player input
# TODO: Interruptions
func process_input():
	directional_input = Vector2()
	if Input.is_action_pressed("right"): 
		directional_input.x += 1
		$AnimatedSprite.flip_h = false
	if Input.is_action_pressed("left"): 
		directional_input.x -= 1
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("down"): directional_input.y += 1
	if Input.is_action_pressed("up"): directional_input.y -= 1
	return directional_input.normalized()
