extends Sprite

onready var cscene = get_tree().current_scene

func _ready():
	$AnimationPlayer.play("idle")

func _on_CollectTrigger_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	cscene.increase_stars()
	cscene.savegame(1)
	queue_free()
