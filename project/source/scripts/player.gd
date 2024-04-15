extends CharacterBody3D

var can_move = true

var speed = 4
const ACCEL_DEFAULT = 15
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5
var cam_accel = 40
var mouse_sense = 0.15
var snap = Vector3()
var direction = Vector3()
var gravity_direction = Vector3(0,-3,0)
var movement = Vector3()

var timeSinceLastWalkCycle = 0;

var is_grabbing = false

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/RayCast3D
@onready var grab_position = $Head/grab_position


@onready var world = $".." #this is bad practice, but too tired to do it properly

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
func _physics_process(delta):
	#get keyboard input
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click"):
		if is_grabbing:
			launch()
		else:
			var collider = raycast.get_collider()
			if collider != null:
				grab(collider)
	
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var input = Input.get_vector("left","right","up","down")
	direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, h_rot).normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	movement = velocity + gravity_direction
	# warning-ignore:return_value_discarded
	if can_move:
		set_velocity(movement)
		# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap`
		set_up_direction(Vector3.UP)
		move_and_slide()
		
		var speed := (velocity * Vector3(1, 0, 1)).length();
		if (speed > 1):
			var thres: float = 1250.0 * (0.736 ** float(speed));
			if (timeSinceLastWalkCycle > thres):
				timeSinceLastWalkCycle = 0;
				get_node("/root/Sounds").playSound(["walk"], -20);
			
		timeSinceLastWalkCycle += delta * 1000;
	
func grab(body: RigidBody3D):
	print("okay")
	world.remove_child(body)
	grab_position.add_child(body)
	body.stop(true)
	body.position = Vector3()
	
	is_grabbing = true
	
	get_node("/root/Sounds").playSound(["pickup"]);

func launch():
	var face_direction = Vector3(0,0,-1).rotated(Vector3(1,0,0),head.rotation.x).rotated(Vector3(0,1,0),rotation.y)
	
	print(grab_position.get_children())
	print("nokay")
	var body = grab_position.get_child(0)
	grab_position.remove_child(body)
	world.add_child(body)
	body.stop(false)
	body.throw(face_direction)
	body.global_position = global_position + face_direction
	
	is_grabbing = false
	
	get_node("/root/Sounds").playSound(["throw"]);
	#okay figure out
