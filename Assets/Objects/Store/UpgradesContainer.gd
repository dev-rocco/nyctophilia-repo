extends VBoxContainer

export(NodePath) var price_check_timer_path
onready var price_check_timer = get_node(price_check_timer_path)

func _ready():
	price_check_timer.start()

func recheck_all():
	for i in get_children():
		i.update_level_text()
	price_check_timer.start()

func _on_PriceCheckTimer_timeout():
	recheck_all()
