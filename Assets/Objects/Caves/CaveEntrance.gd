extends Node2D

onready var occluders = $Occluders
onready var colliders = $Colliders
var orig_collision_layers = []

func _ready():
	for x in colliders.get_child_count():
		for i in colliders.get_children():
			orig_collision_layers.append({"layer":i.collision_layer, "mask":i.collision_mask})

func disable_coll():
	for i in colliders.get_children():
		i.collision_layer = 0
		i.collision_mask = 0
func enable_coll():
	for i in colliders.get_child_count():
		colliders.get_child(i).collision_layer = orig_collision_layers[i]["layer"]
		colliders.get_child(i).collision_mask = orig_collision_layers[i]["mask"]
	

func _on_CE_Trigger_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	occluders.visible = true
	enable_coll()
func _on_CE_Trigger_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	occluders.visible = false
	disable_coll()
