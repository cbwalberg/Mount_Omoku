extends Node2D


@export var beacon_size: float = 25
@export var beacon_lerp_weight: float = 10.0		# multiplied by delta
@export var deccelerate_zone_radius: float = 1500

var mouse_delta: Vector2 = Vector2.ZERO
var mouse_speed: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)	# TODO: change to MOUSE_MODE_CONFINED_HIDDEN after creating Pause scene


func start(pos):
	global_position = pos
	$Size/CollisionShape2D.apply_scale(Vector2(beacon_size, beacon_size))
	$Decceleration_zone/CollisionShape2D.apply_scale(Vector2(deccelerate_zone_radius, deccelerate_zone_radius))
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	$AnimatedSprite2D.position = $AnimatedSprite2D.position.lerp(get_local_mouse_position(), beacon_lerp_weight * delta)
#	queue_redraw()
#
#
#func _draw():
#	draw_arc($AnimatedSprite2D.position, deccelerate_zone_radius, 0.0, TAU, 50, Color.DARK_RED, 2.5) 
