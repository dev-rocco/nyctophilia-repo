extends Control

export var start_scene = "res://Scenes/DevScene.tscn"
onready var options_panel = $OptionsControl

### GENERAL ###
func _on_Start_pressed():
	if accept_inputs:
		print("starting "+start_scene)
		var _DISC_cs = get_tree().change_scene(start_scene)

var options_alert_displayed = true
func _on_Options_pressed():
	if accept_inputs:
		if !options_alert_displayed:
			options_alert_displayed = true
			if OS.get_name() == "X11" or OS.get_name() == "OSX":
				OS.alert("Display modes are only confirmed to work on Windows; On Linux (X11), using borderless and switching to another display mode will cause the menu to freeze.\n\nIf you have issues, delete the \"settings.dat\" and \"autoload\" files in the folder containing the game and launch it again.","Read me!!")
		if options_panel.visible:
			options_panel.visible = false
		else:
			options_panel.visible = true

### OPTIONS ###
# Display #
onready var res_width_box = $OptionsControl/TabCon/Display/Display/Dimensions/Width/Width
onready var res_height_box = $OptionsControl/TabCon/Display/Display/Dimensions/Height/Height
onready var display_vsync_button = $OptionsControl/TabCon/Display/Display/Modes/Buttons/VSync
## applied vars
var res_width = 854
var res_height = 480
var screen_mode = 0
var display_vsync = false
##
func _on_ResWidth_text_changed():
	if accept_inputs:
		res_width = res_width_box.text
func _on_ResHeight_text_changed():
	if accept_inputs:
		res_height = res_height_box.text

const MAX_RES = 3840
const MIN_RES = 480
func apply_display():
	# resolution
	if (int(res_width) >= MIN_RES and int(res_height) >= MIN_RES) and (int(res_width) < MAX_RES and int(res_height) < MAX_RES):
		OS.set_window_size(Vector2(res_width, res_height))
	else:
		print("invalid resolution")
	
	# mode
	if (screen_mode is int) and (screen_mode == 0 or screen_mode == 1 or screen_mode == 2):
		if screen_mode == 0:
			OS.set_window_fullscreen(false)
			#OS.set_window_maximized(false)
			OS.set_borderless_window(false)
			OS.window_position = Vector2(0,0)
		elif screen_mode == 1:
			OS.set_window_fullscreen(true)
			#OS.set_window_maximized(false)
			OS.set_borderless_window(false)
		elif screen_mode == 2:
			OS.set_window_fullscreen(false)
			#OS.set_window_maximized(true)
			OS.set_borderless_window(true)
			OS.window_position = Vector2(0,0)
	else:
		OS.alert("screen_mode has invalid value ("+str(screen_mode)+").\nSetting screen_mode to 0 (windowed).", "Display options error")
		screen_mode = 0
		apply_display()
	
	# vsync
	if display_vsync is bool:
		OS.set_use_vsync(display_vsync)
	else:
		OS.alert("display_vsync has invalid value ("+str(display_vsync)+").\nDisabling V-Sync.", "Display options error")

func _on_WindowedMode_pressed():
	if accept_inputs:
		screen_mode = 0
func _on_FullscreenMode_pressed():
	if accept_inputs:
		screen_mode = 1
func _on_BorderlessMode_pressed():
	if accept_inputs:
		screen_mode = 2

func _on_VSync_toggled(button_pressed):
	if accept_inputs:
		display_vsync = button_pressed
###########################


func apply_all_settings():
	apply_display()
	apply_timer.stop()
	accept_inputs = true

var accept_inputs = true
func apply_all_settings_on_timer():
	apply_all_settings()
	accept_inputs = false
	apply_timer.start()
	
func _on_ApplyChanges_pressed():
	apply_all_settings_on_timer()




#### SAVING AND LOADING ####
onready var apply_timer = $ApplyTimer

const GAMEFILES_LOC = "res://gamefiles/"
const SAVE_LOC = "res://gamefiles/settings.dat"
const AUTOLOAD_LOC = "res://gamefiles/autoload"
var display_res = Vector2()
var load_autoload = false
var temp_dir = Directory.new()

func _ready():
	options_panel.visible = false
	if temp_dir.file_exists(AUTOLOAD_LOC) and temp_dir.file_exists(SAVE_LOC):
		print("autoloaded settings")
		$OptionsControl/Apply/Autoload.pressed = true
		load_all_settings()

func save_all_settings():
	if temp_dir.dir_exists(GAMEFILES_LOC):
		var temp_file = File.new()
		temp_file.open(SAVE_LOC, File.WRITE)
		#
		temp_file.store_var(Vector2(res_width, res_height))
		temp_file.store_var(screen_mode)
		temp_file.store_var(display_vsync)
		#
		temp_file.close()
	else:
		temp_dir.open("res://")
		temp_dir.make_dir("gamefiles")
		save_all_settings()

func load_all_settings():
	var temp_file = File.new()
	temp_file.open(SAVE_LOC, File.READ)
	#
	display_res = temp_file.get_var()
	res_width = display_res.x
	res_height = display_res.y
	res_width_box.text = str(res_width)
	res_height_box.text = str(res_height)
	
	screen_mode = temp_file.get_var()
	
	display_vsync = temp_file.get_var()
	display_vsync_button.pressed = display_vsync
	#
	apply_all_settings_on_timer()


func _on_SaveChanges_pressed():
	if accept_inputs:
		save_all_settings()
func _on_LoadChanges_pressed():
	if accept_inputs:
		load_all_settings()


func _on_Autoload_toggled(button_pressed):
	if button_pressed:
		var temp_file = File.new()
		temp_file.open(AUTOLOAD_LOC, File.WRITE)
		temp_file.store_string("0")
		temp_file.close()
	else:
		temp_dir.remove(AUTOLOAD_LOC)
##################################


func _on_Quit_pressed():
	get_tree().quit()


func _on_ApplyTimer_timeout():
	apply_all_settings()
