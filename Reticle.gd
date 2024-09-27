extends CenterContainer
@export var DOT_RADIUS : float = 1.5
@export var DOT_COLOR : Color = Color.WHITE
@export var RETICLE_LINES : Array[Line2D]
@export var RETICLE_SPEED : float = 0.35
@export var RETICLE_DISTANCE : float = 4.0
@export var PLAYER_CONTROLLER : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw() # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	adjust_reticle_lines()
	
func _draw():
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR)
	
func adjust_reticle_lines():
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	var origin = Vector3(0,0,0)
	var pos = Vector2(0,0)
	#var speed = origin.distance_to(vel)
	var speed = vel.length()
	
	#Adjust reticle line position
	#top
	RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, Vector2(0,-speed * RETICLE_DISTANCE), RETICLE_SPEED)
	#right
	RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
	#bottom
	RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED)
	#left
	RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
