extends RigidBody3D

@export var soundName: String = "vase";

@export var damage_threshold: float
@export var shatter_threshold: float
@export var throw_speed: float
@export var explosion_radius: float = 0.5;
@export var explosion_damage: float = 50;
@export var score: float = 1000

@export var max_health: int

@onready var health = max_health

@onready var model = $model
var isDead: bool = false;
@onready var world: Node = $"/root/game/breakables";

func damage():
	print("jheaf")
	$CPUParticles3D.restart()
	health -= 1
	if health <= 0:
		shatter();
	else:
		get_node("/root/game/UI/score").damage.emit(score);
		get_node("/root/Sounds").play3DSound(["damage", soundName], self.position);

func shatter():
	if (isDead):
		return;

	isDead = true;
	get_node("/root/Sounds").play3DSound(["breaking", soundName], self.position);
	
	stop(true)
	model.visible = false
	$CPUParticles3D.restart()
	get_node("/root/game/UI/score").destruction.emit(score);
	
	if (explosion_radius > 0):
		for child in world.get_children():
			if (child != self && !child.isDead):
				var distance: float = self.global_position.distance_to(child.global_position);
				if (distance < explosion_radius):
					var adjusted: float = (-(distance / explosion_radius) ** 4 + 1) * explosion_damage;
					child.tryTakeDamage(adjusted);
	
	await $CPUParticles3D.finished
	queue_free()

func throw(direction: Vector3):
	#var direction = global_position.direction_to(origin)
	apply_impulse(direction * throw_speed)

func _on_body_entered(body):
	var speed = linear_velocity.length_squared()
	tryTakeDamage(speed);

func tryTakeDamage(amt: float):
	if (isDead):
		return;
		
	if amt > damage_threshold:
		if amt > shatter_threshold:
			shatter()
		else:
			damage()
	else:
		get_node("/root/Sounds").play3DSound(["bounce", soundName], self.position);

func stop(stop: bool = true):
	freeze = stop
	$CollisionShape3D.set_deferred("disabled",stop)
