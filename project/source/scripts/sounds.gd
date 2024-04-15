extends Node

# layout should match sounds folder layout
const SOUNDS := {
	"breaking": {
		"vase": [
			"vase1.wav",
			"vase2.wav",
			"vase3.wav",
			"vase4.wav"
		]
	},
	"damage": {
		"vase": "hit1.wav"
	},
	"bounce": {
		"vase": "bounce1.wav"
	},
	"walk": [
		"_footsteps1.wav",
		"_footsteps2.wav",
		"_footsteps3.wav",
		"_footsteps4.wav",
		"_footsteps5.wav",
		"_footsteps6.wav"
	],
	"throw": "throw.wav",
	"pickup": "pickup.wav"
};

const SOUND_3D_PREFAB := preload("res://source/assets/sounds/sound_player_3d.tscn");
const SOUND_PREFAB := preload("res://source/assets/sounds/sound_player.tscn");

var rng := RandomNumberGenerator.new();

func getSound(path: Array) -> String:
	var child = SOUNDS;
	var fullPath = "res://source/assets/sounds";
	for s in path:
		child = child[s];
		fullPath += "/" + s;
	
	# type can be either a list of possible sounds or a singular sound
	var p: String = child if child is String else child[rng.randi_range(0, child.size() - 1)];
	fullPath += "/" + p;
	
	return fullPath;

func play3DSound(path: Array, position: Vector3, vol: float = 0) -> void:
	var player := SOUND_3D_PREFAB.instantiate();
	player.position = position;
	player.volume_db = vol;
	get_node("/root/Sounds").add_child(player);
	
	player.stream = load(getSound(path));
	player.play();
	
	player.finished.connect(func(): player.queue_free());

func playSound(path: Array, vol: float = 0) -> void:
	var player := SOUND_PREFAB.instantiate();
	player.volume_db = vol;
	get_node("/root/Sounds").add_child(player);
	
	player.stream = load(getSound(path));
	player.play();
	
	player.finished.connect(func(): player.queue_free());
