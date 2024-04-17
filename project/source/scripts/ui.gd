extends Node

@export var player: Node;

var crosshairNone = preload("res://source/assets/UI/crosshairs/crossNone.png");
var crosshairHover = preload("res://source/assets/UI/crosshairs/crossHover.png");
var crosshairGrab = preload("res://source/assets/UI/crosshairs/crossGrab.png");

func _physics_process(delta: float) -> void:
	if (player.is_grabbing):
		%crosshair.texture = crosshairGrab;
	elif (player.get_node("./Head/RayCast3D").get_collider()):
		%crosshair.texture = crosshairHover;
	else:
		%crosshair.texture = crosshairNone;
