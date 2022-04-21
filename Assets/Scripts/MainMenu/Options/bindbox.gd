extends HBoxContainer

func set_bind(_action, _key):
	pass
func clr_bind(action):
	if !InputMap.get_action_list(action).empty():
		InputMap.action_erase_event(action, InputMap.get_action_list(action)[0])

func _on_Bind1_pressed():
	pass # Replace with function body.

func _on_Bind2_pressed():
	pass # Replace with function body.
