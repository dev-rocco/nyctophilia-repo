extends StaticBody2D

onready var audio_player = $AudioStreamPlayer
var has_gold = true

func use():
	if has_gold:
		get_tree().current_scene.increase_gold(50)
		$ItemSpawnParent/Sprite.queue_free()
		audio_player.play()
		has_gold = false

func get_has_gold():
	return has_gold
