extends CharacterBody3D

const SPEED_DEFAULT = 5.0
const SPEED_CROUCH = 2.0
const JUMP_VELOCITY = 4.5

@export var _speed : float
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _is_crouching : bool = false

#export lets me adjust the values in the editor in real time
var MOUSE_SENSITIVITY : float = 0.3
var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@onready var CAMERA_CONTROLLER : Camera3D = get_node("CameraController/Camera3D") 
@onready var ANIMATIONPLAYER : AnimationPlayer = get_node("AnimationPlayer")
@export var CROUCH_SHAPECAST : ShapeCast3D #= get_node("ShapeCast3D")
var CROUCH_SPEED : float = 7.0
@export var TOGGLE_CROUCH : bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("crouch") and is_on_floor() and TOGGLE_CROUCH == true:
		toggle_crouch()
	#Hold to crouch
	if event.is_action_pressed("crouch") and TOGGLE_CROUCH == false and _is_crouching == false:
		crouching(true) 
		print('crouch pressed')
	#Release to uncrouch
	if event.is_action_released("crouch") and TOGGLE_CROUCH == false:
		if CROUCH_SHAPECAST.is_colliding() == false:
			print("crouching false")
			crouching(false)
		elif CROUCH_SHAPECAST.is_colliding() == true:
			uncrouch_check()

func _ready():
	_speed = SPEED_DEFAULT
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

func toggle_crouch():
	if _is_crouching and CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
		print("toggle crouch crouch false shapecast false")
	elif !_is_crouching:
		print("toggle crouch true")
		crouching(true)

func uncrouch_check():
	if CROUCH_SHAPECAST.is_colliding() == false:
		 # Check if the crouch button is being pressed, we are on the floor and we are already crouching. If so, return early without un-crouching
		if Input.is_action_pressed("crouch") and is_on_floor() and _is_crouching == true and TOGGLE_CROUCH == false:
			return
		print("uncrouch check is colliding false")
		crouching(false)
	if CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()

func crouching(state: bool):
	match state:
		true: 
			ANIMATIONPLAYER.play("crouch", 0, CROUCH_SPEED)
			set_movement_speed("crouching")
		false:
			ANIMATIONPLAYER.play("crouch", 0, -CROUCH_SPEED, true)
			set_movement_speed("default")

func _physics_process(delta):
	Global.debug.track_and_update_property("MovementSpeed",_speed,1)
	if CROUCH_SHAPECAST.is_colliding():
		print("colliding with" + CROUCH_SHAPECAST.get_collider(0).to_string())
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == false:
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == true:
		velocity.y = JUMP_VELOCITY
		_speed = SPEED_DEFAULT

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)

	move_and_slide()
	
	#below is used to get the last collision, needs filtering to filter out the map.
	#print(get_last_slide_collision())

func set_movement_speed(state: String):
	match state:
		"default":
			_speed = SPEED_DEFAULT
		"crouching":
			_speed = SPEED_CROUCH

func _on_animation_player_animation_start(anim_name):
	if anim_name == "crouch":
		_is_crouching = !_is_crouching
