extends Button

export(String) var store_type
onready var cscene = get_tree().current_scene
onready var level_text = $LevelText
onready var orig_text = text

func update_level_text():
	level_text.text = "Level "+str(cscene.get_store_level(store_type))
	text = orig_text+"  $"+str(cscene.get_store_price(store_type))
	if cscene.get_gold() < cscene.get_store_price(store_type):
		disabled = true
	else:
		disabled = false

func _on_pressed():
	cscene.upgrade(store_type)
	get_parent().recheck_all()
