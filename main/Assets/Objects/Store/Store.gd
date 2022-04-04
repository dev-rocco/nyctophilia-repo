extends StaticBody2D

export(bool) var enabled = true
export(NodePath) var player_path
onready var player = get_node(player_path)
onready var audio_player = $AudioStreamPlayer
onready var open_delay = $OpenDelay
onready var cscene = get_tree().current_scene

var shop_open = false

func hide():
	player.show_gui()
	$CanvasLayer/Control.visible = false
func show():
	player.hide_gui()
	$CanvasLayer/Control.visible = true

func _ready():
	$CanvasLayer/Control.visible = false
	if player == null:
		print(str(self)+": player_path null, disabling shop")
		enabled = false

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("interact") and shop_open:
			hide()

onready var gold_counter = $CanvasLayer/Control/Panel/GoldCounter
func _process(_delta):
	gold_counter.text = "$"+str(cscene.get_gold())

var can_open = true
func use():
	if enabled:
		if shop_open:
			can_open = false
			open_delay.start()
			shop_open = false
			print(str(self)+": menu closed")
			hide()
		if !shop_open and can_open:
			shop_open = true
			print(str(self)+": menu opened")
			show()
			audio_player.play()


func _on_OpenDelay_timeout():
	can_open = true
