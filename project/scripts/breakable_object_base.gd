extends RigidBody3D


func shatter():
	freeze = true
	$MeshInstance3D.hide()
	$CPUParticles3D.restart()
	await $CPUParticles3D.finished
	queue_free()

func kick(origin: Vector3):
	var direction = global_position.direction_to(origin)
	apply_impulse(direction * -2)

func _on_break_sensor_body_entered(body):
	if body.is_in_group("floor"):
		shatter()
