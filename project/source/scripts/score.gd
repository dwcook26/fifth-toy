extends Node

@export var scoreList: Node;
@export var scoreText: Node;
var score: float = 0;
@onready var baseScoreTextPos: Vector2 = scoreText.position;
var scoreOffsetPos: Vector2 = Vector2(0, 0);

var scoreUpdate = preload("res://source/scenes/score_update.tscn");
var comboMemory: Array[int] = [];

var scoreThresholds: Dictionary = {
	2000: Color(0, 0, 0),
	5000: Color()
}

# id : [obj, lifespan]
# known ids:
# -1 -> none
# 0 -> combo
var existingScoreUpdates: Dictionary = {};
var rollingScoreUpdateId: int = 100;
var lifespanUpdate: float = 2;

signal destruction(change: float);
signal damage(change: float);

func _process(delta: float) -> void:
	updateShake(delta);
	updateScoreChange(delta);

func _on_destruction(change: float) -> void:
	var cur: int = Time.get_ticks_msec();
	comboMemory.append(cur);
	var j: int = comboMemory.size();
	for i in range(j):
		if cur - comboMemory[0] > 100:
			comboMemory.pop_front();
		else:
			break;

	var n: int = comboMemory.size();
	updateScore(change * n);
	if (n > 1):
		notifyScoreChange("+[color=#FFDF00]COMBO x" + str(comboMemory.size()), 0);
	else:
		notifyScoreChange("+[color=#ff0000]Destruction");

func _on_damage(change: float) -> void:
	updateScore(change / 2);

func updateScore(change: float) -> void:
	score += change;
	scoreText.text = "[right]" + str(score);
	
	addShake(change / 9_000);

func notifyScoreChange(text: String, id: int = -1):
	text = "[right]" + text;
	if (id == -1):
		id = rollingScoreUpdateId;
		rollingScoreUpdateId += 1;
		
	if (!(id in existingScoreUpdates)):
		var t: Node = scoreUpdate.instantiate();
		$change.add_child(t);
		t.position = Vector2(-159, 78);
		existingScoreUpdates[id] = [t, lifespanUpdate];
	
	existingScoreUpdates[id][0].text = text;
	existingScoreUpdates[id][1] = lifespanUpdate;

func updateScoreChange(delta: float):
	var sorted: Array = [];
	for id in existingScoreUpdates:
		var arr: Array = existingScoreUpdates[id];
		arr[1] -= delta;
		
		if (arr[1] <= 0):
			arr[0].queue_free();
			existingScoreUpdates.erase(id);
		else:
			sorted.append(arr);
	
	sorted.sort_custom(func(a, b): return a[1] < b[1]);
	var i: int = 0;
	for arr in sorted: # constant, shhhhh
		arr[0].position.y = 78 + 30 * i;
		arr[0].modulate.a = -((1 - arr[1] / lifespanUpdate)) ** 4 + 1
		i += 1;

# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html
var shake: float = 0;
func addShake(a: float):
	shake = min(shake + a, 1);

func updateShake(delta: float):
	if (shake > 0):
		shake = max(shake - float(1) * delta, 0);
		
		var amount: float = pow(shake, 2);
		scoreText.rotation = float(0.5) * amount * randf_range(-1, 1);
		scoreOffsetPos = Vector2(
			200 * amount * randf_range(-1, 1),
			150 * amount * randf_range(-1, 1)
		);
		
		scoreText.position = baseScoreTextPos + scoreOffsetPos;
		# dont seem to be able to change origin of node, so change text size instead
		var fontChange = 20 * shake;
		scoreText.add_theme_font_size_override("normal_font_size", 40 + fontChange);
