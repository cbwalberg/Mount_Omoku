extends Node2D


# TODO: set position = mouse in _phyics_process, create 2d area child node called deccelerate zone
# draw deccel zone and small circle around mouse (dif colors) for viz testing
@export var beacon_size: float = 25
@export var deccelerate_zone_radius: float = 1000

var mouse_delta: Vector2 = Vector2.ZERO
var mouse_speed: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func start(pos):
	global_position = pos
	$Size/CollisionShape2D.apply_scale(Vector2(beacon_size, beacon_size))
	$Size/CollisionShape2D.disabled = false
	$Decceleration_zone/CollisionShape2D.apply_scale(Vector2(deccelerate_zone_radius, deccelerate_zone_radius))
	$Decceleration_zone/CollisionShape2D.disabled = false
	show()


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		mouse_speed = event.velocity
		# print(mouse_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += mouse_delta	# * mouse_speed * delta
	# force_update_transform() # force physics engine to update transform values for use in code
#	queue_redraw() # calls _draw()


func _physics_process(delta):
	pass


func get_deccelerate_zone_radius():
	return deccelerate_zone_radius
