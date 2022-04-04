extends Control

var paused = false
onready var cscene = get_tree().current_scene

func _ready():
	visible = paused

func toggle_pause():
	if paused:
		get_tree().paused = PAUSE_MODE_INHERIT
		paused = false
		visible = false
	elif !paused:
		get_tree().paused = PAUSE_MODE_PROCESS
		paused = true
		visible = true

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			toggle_pause()


func _on_Resume_pressed():
	toggle_pause()

func _on_Save_pressed():
	cscene.savegame()
func _on_Load_pressed():
	cscene.loadgame()


func _on_QuitToMenu_pressed():
	get_tree().change_scene("res://Scenes/DevMainMenu.tscn")
func _on_QuitToDesktop_pressed():
	get_tree().quit()


