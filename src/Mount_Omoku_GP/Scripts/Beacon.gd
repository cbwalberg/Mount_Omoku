extends Node2D


# TODO: set position = mouse in _phyics_process, create 2d area child node called deccelerate zone
# draw deccel zone and small circle around mouse (dif colors) for viz testing
@export var beacon_size: float = 25
@export var deccelerate_zone_radius: float = 1000


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func start(pos):
	position = pos
	$Decceleration_zone/CollisionShape2D.apply_scale(Vector2(deccelerate_zone_radius, deccelerate_zone_radius))
	$Decceleration_zone/CollisionShape2D.disabled = false
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position()
	# force_update_transform() # force physics engine to update transform values for use in code
	queue_redraw() # calls _draw()


func _physics_process(delta):
	pass


func _draw():
	draw_circle(position, beacon_size, Color.GOLD)
	draw_arc(position, deccelerate_zone_radius, 0.0, TAU, 50, Color.DARK_RED, 2.5)
