extends Node2D

var orig_collision_layers = []

func _ready():
	for x in get_child_count():
		for i in get_children():
			orig_collision_layers.append({"layer":i.collision_layer, "mask":i.collision_mask})

func hide():
	visible = false
	for i in get_children():
		i.collision_layer = 0
		i.collision_mask = 0
func show():
	visible = true
	for i in get_child_count():
		get_child(i).collision_layer = orig_collision_layers[i]["layer"]
		get_child(i).collision_mask = orig_collision_layers[i]["mask"]
