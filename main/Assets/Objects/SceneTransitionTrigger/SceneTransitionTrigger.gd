extends Area2D

export(bool) var enabled = true
export(bool) var force_rootget_player = false
export(String) var loc_or_obj = "loc"
export(Vector2) var new_loc = Vector2(100,100)
export(NodePath) var new_loc_obj_path
var new_loc_obj

export(NodePath) var player_path
var player

onready var timer = $Timer
onready var smoothing_timer = $SmoothingTimer
var player_cam

onready var audio_player = $AudioStreamPlayer

func rootget_player():
	player = get_tree().current_scene.get_player()
	if !player:
		print(str(self)+": rootget failed; disabling trigger.")
	else:
		print(str(self)+": rootget successful; using "+str(player)+".")
		player_cam = player.get_node("Camera")

func _ready():
	if force_rootget_player:
		rootget_player()
	else:
		player = get_node(player_path)
		if !player:
			print(str(self)+": player_path invalid or not set; trying rootget.")
			rootget_player()
		else:
			player_cam = player.get_node("Camera")
	if enabled:
		if loc_or_obj != "loc" and loc_or_obj != "obj":
			print(str(self)+": WARNING: loc_or_obj has invalid value ("+loc_or_obj+") - disabling trigger.")
			enabled = false
		elif loc_or_obj == "obj":
			new_loc_obj = get_node(new_loc_obj_path)

func transition():
	if enabled:
		player.black_fadein()
		timer.start()

func move_player(player_obj):
	if enabled:
		audio_player.play()
		if loc_or_obj == "loc":
			player_obj.global_transform.origin = new_loc
		elif loc_or_obj == "obj":
			player_obj.global_transform.origin = new_loc_obj.global_transform.origin

func _on_Timer_timeout():
	if enabled:
		if player.get_blackout_animating():
			timer.start()
		else:
			player_cam.smoothing_enabled = false
			move_player(player)
			timer.stop()
			smoothing_timer.start()
			player.black_fadeout()

func _on_SmoothingTimer_timeout():
	if enabled:
		player_cam.smoothing_enabled = true
		smoothing_timer.stop()

func _on_SceneTransitionTrigger_body_entered(_body):
	transition()
