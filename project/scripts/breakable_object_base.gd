extends RigidBody3D

@export var damage_threshold: float
@export var shatter_threshold: float
@export var throw_speed: float

@export var max_health: int

@onready var health = max_health

@onready var model = $model
@onready var world = $".."

func damage():
	print("jheaf")
	$CPUParticles3D.restart()
	health -= 1
	if health <= 0:
		shatter()

func shatter():
	
	stop(true)
	model.visible = false
	$CPUParticles3D.restart()
	await $CPUParticles3D.finished
	queue_free()

func throw(direction: Vector3):
	#var direction = global_position.direction_to(origin)
	apply_impulse(direction * throw_speed)

func _on_body_entered(body):
	var speed = linear_velocity.length_squared()
	if speed > damage_threshold:
		if speed > shatter_threshold:
			shatter()
		else:
			damage()

func stop(stop: bool = true):
	freeze = stop
	$CollisionShape3D.set_deferred("disabled",stop)
