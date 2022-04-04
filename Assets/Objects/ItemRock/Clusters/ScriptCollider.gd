extends StaticBody2D

onready var IR_parent = $"../ItemRocks"
var IR_arr = []

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	for i in IR_parent.get_children():
		IR_arr.push_back(i)

func use():
	if IR_arr.size() > 0:
		var i = rng.randi_range(0, IR_arr.size() - 1)
		if IR_arr[i].get_has_gold():
			IR_arr[i].use()
		IR_arr.remove(i)
