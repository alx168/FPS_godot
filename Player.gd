extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _is_crouching : bool = false

#export lets me adjust the values in the editor in real time
@export var MOUSE_SENSITIVITY : float = 0.3
var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@onready var CAMERA_CONTROLLER : Camera3D = get_node("CameraController/Camera3D") 
@onready var ANIMATIONPLAYER : AnimationPlayer = get_node("AnimationPlayer")
@export var CROUCH_SHAPECAST : ShapeCast3D #= get_node("ShapeCast3D")
var CROUCH_SPEED : float = 7.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUCH_SHAPECAST.add_exception($".")
	
func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		#print(Vector2(_rotation_input, _tilt_input))
	if event.is_action_pressed("crouch"):
		toggle_crouch()

func toggle_crouch():
	if _is_crouching and CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATIONPLAYER.play("crouch", -1, -CROUCH_SPEED, true)
		#print("now not crouching")
	elif !_is_crouching:
		#print("now crouching")
		ANIMATIONPLAYER.play("crouch", -1, CROUCH_SPEED)

func _physics_process(delta):
	if CROUCH_SHAPECAST.is_colliding():
		print("colliding with" + CROUCH_SHAPECAST.get_collider(0).to_string())
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#below is used to get the last collision, needs filtering to filter out the map.
	#print(get_last_slide_collision())

func _on_animation_player_animation_started(anim_name):
	if anim_name == "crouch":
		_is_crouching = !_is_crouching
