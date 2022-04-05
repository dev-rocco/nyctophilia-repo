extends KinematicBody2D

class_name Player_Controller

# Vars (no shit) #
# land
export var land_grav = 15
export var land_terminal_y_velocity = 1000
export var land_terminal_x_velocity = 300
export var land_accel = 20
export var land_friction_multiplier = 0.92
export var land_jump_velocity = 400
# water
export var water_terminal_y_velocity = 500
export var water_terminal_x_velocity = 150
export var water_accel = Vector2(5,5)
onready var true_water_accel = water_accel
export var water_friction_multiplier = 0.96
export var water_jumpout_velocity = 250
# in_water
export var max_oxygen = 100
onready var starting_oxygen = max_oxygen
export var starting_oxygen_depletion_rate = 5
export(float) var starting_oxygen_regen_rate = starting_oxygen_depletion_rate / 2
var true_oxygen_regen_rate = starting_oxygen_regen_rate
var true_oxygen_depletion_rate = starting_oxygen_depletion_rate
var oxygen_remaining = 100
onready var world_lighting = $WorldLighting
# other
var on_ground = false
var can_jump = false
onready var jump_timer = $JumpTimer
var in_water = false
var underwater = false
var facing_dir = "r"
var ic_checkerl_cbody = null
var ic_checkerr_cbody = null
var freeze_movement = false
# health
export var max_health = 100
export var max_sanity = 100
var sanity = max_sanity
var health = max_health
# UI
onready var UI_control = $Camera/UI/Control
onready var oxygen_counter = $Camera/UI/Control/Oxygen/OxygenRemaining
onready var health_counter = $Camera/UI/Control/Health/HealthRemaining
onready var gold_counter = $Camera/UI/Control/Gold/GoldRemaining
onready var sanity_counter = $Camera/UI/Control/Sanity/SanityRemaining
onready var blackout_animator = $Camera/UI/Blackout/AnimationPlayer
onready var stars_counter = $Camera/UI/Control/Stars/StarsCount
onready var role_text = $Camera/UI/Control/Role/RoleText
var blackout_animating = false
## audio TEMPORARY
onready var audio_player = $AudioStreamPlayer
const audio_folder_path = "res://Assets/Resources/Audio/sfxia/exports/"
# sound list
var sound_death = load(audio_folder_path+"death_2.wav")
var sound_hurt_1 = load(audio_folder_path+"hurt_1.wav")
var sound_hurt_2 = load(audio_folder_path+"hurt_2.wav")
var sound_hurt_3 = load(audio_folder_path+"hurt_3.wav")
# animation
onready var sprite_animator = $Sprite/AnimationPlayer
# UI bars
onready var sanity_bar = $Camera/UI/Bars/SanityBar
onready var sanity_bar_max = sanity_bar.rect_size.x
onready var health_bar = $Camera/UI/Bars/HealthBar
onready var health_bar_max = health_bar.rect_size.x
onready var oxygen_bar = $Camera/UI/Bars/OxygenBar
onready var oxygen_bar_max = oxygen_bar.rect_size.x
###############################
onready var cscene = get_tree().current_scene

# Custom functions #
# interactions
func check_interact():
	if !freeze_movement:
		if facing_dir == "r" and ic_checkerr_cbody != null:
			ic_checkerr_cbody.use()
		elif facing_dir == "l" and ic_checkerl_cbody != null:
			ic_checkerl_cbody.use()

# blackout
func black_fadein():
	blackout_animator.play("BlackFadeIn")
func black_fadeout():
	blackout_animator.play("BlackFadeOut")
func get_blackout_animating():
	return blackout_animating

# audio
func play_sound(sound_var):
	audio_player.stream = sound_var
	audio_player.play()

# enemy chance handler (sanity)
onready var enemy_try_timer = $EnemyTryTimer
var in_water_starty = null
var being_attacked = false
func try_enemy():
	if world_lighting_enabled:
		fake_enemy.decide_attack()
		enemy_try_timer.start(sanity/2)
	else:
		enemy_try_timer.stop()

# death
onready var death_timer = $DeathTimer
var temp_dead = false
func dying():
	if is_instance_valid($Sprite):
		if !temp_dead:
			temp_dead = true
			$Sprite.visible = false
			freeze_movement = true
			play_sound(sound_death)
			death_timer.start()
func dead():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

var world_lighting_enabled = true
var world_lighting_changespeed = 2.5
onready var temp_light = world_lighting.get_node("Light")
onready var temp_cm = world_lighting.get_node("CanvasModulate")
func enable_world_lighting(delta):
	temp_light.energy = lerp(temp_light.energy, 1, world_lighting_changespeed * delta)
	temp_cm.color = lerp(temp_cm.color, Color(0,0,0,1), world_lighting_changespeed * delta)
func disable_world_lighting(delta):
	temp_light.energy = lerp(temp_light.energy, 0, world_lighting_changespeed * delta)
	temp_cm.color = lerp(temp_cm.color, Color(1,1,1,1), world_lighting_changespeed * delta)
########################################

# Main #
export(NodePath) var fake_enemy_path
var fake_enemy
func _ready():
	UI_control.visible = true
	blackout_animator.get_parent().visible = true
	blackout_animator.play("BlackFadeOut")
	world_lighting.visible = true
	sprite_animator.play("idle")
	jump_timer.start()
	if fake_enemy_path:
		fake_enemy = get_node(fake_enemy_path)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("interact"):
			check_interact()
		
		# Look dir
		if event.is_action_pressed("move_right"):
			facing_dir = "r"
		if event.is_action_pressed("move_left"):
			facing_dir = "l"
		
		# enemy debug
		if event.is_action_pressed("flashlight_toggle"):
			fake_enemy.attack()

func _process(delta):
	# Upgrades updater (pretty fucking slow but idgaf cos am dead hard)
	true_oxygen_depletion_rate = starting_oxygen_depletion_rate - (cscene.get_store_level("oxygen") / 2)
	true_oxygen_regen_rate = starting_oxygen_regen_rate + (cscene.get_store_level("oxygen_regen"))
	true_water_accel = water_accel + Vector2(cscene.get_store_level("swim_speed") / 2, cscene.get_store_level("swim_speed") / 2)
	
	# Underwater handling (oxygen and health depletion)
	if underwater and oxygen_remaining > 0:
		oxygen_remaining -= true_oxygen_depletion_rate * delta
	elif not underwater and oxygen_remaining < max_oxygen:
		oxygen_remaining += (true_oxygen_regen_rate) * delta
	if underwater and oxygen_remaining <= 0:
		health -= (starting_oxygen_depletion_rate * 3) * delta
	
	# Death check
	#if health <= 0:
	#	dying()
	
	# Water lighting (darkness)
	if world_lighting_enabled:
		enable_world_lighting(delta)
	else:
		disable_world_lighting(delta)
	
	# Quick fixes
	if oxygen_remaining < 0:
		oxygen_remaining = 0
	if health < 0:
		health = 0
	
	# set sanity
	if in_water_starty:
		if global_transform.origin.y > in_water_starty:
			sanity = 100 - ((global_transform.origin.y - in_water_starty) / max_sanity)
	if fake_enemy.get_attacking():
		being_attacked = true
	else:
		being_attacked = false
	
	# Update counters
	oxygen_counter.text = str(round(oxygen_remaining))+"%"
	health_counter.text = str(round(health))+"%"
	gold_counter.text = "$"+str(get_tree().current_scene.get_gold())
	sanity_counter.text = str(round(sanity))+"%"
	stars_counter.text = str(cscene.get_stars())
	role_text.text = cscene.get_player_role()
	
	# Update bars
	# TEMPORARY
	sanity_bar.rect_scale.x = sanity/100
	health_bar.rect_scale.x = health/100
	oxygen_bar.rect_scale.x = oxygen_remaining/100


var velocity = Vector2(0,0)
func _physics_process(delta):
	var direction = Vector2(0,0)
	
	if !freeze_movement and !being_attacked:
		## Land movement ##
		if !in_water:
			# Input #
			if Input.is_action_pressed("move_right") and velocity.x < land_terminal_x_velocity:
				direction.x += land_accel
			if Input.is_action_pressed("move_left") and velocity.x > -land_terminal_x_velocity:
				direction.x -= land_accel
			if Input.is_action_pressed("move_up") and can_jump and on_ground:
				can_jump = false
				on_ground = false
				jump_timer.stop()
				direction.y -= land_jump_velocity
			
			if velocity.y < land_terminal_y_velocity:
				velocity.y += land_grav
			if is_on_floor():
				velocity.y = 0
			
			velocity.x *= land_friction_multiplier
		## in_water movement ##
		elif in_water:
			# Input #
			if Input.is_action_pressed("move_right") and velocity.x < water_terminal_x_velocity:
				direction.x += true_water_accel.x
			if Input.is_action_pressed("move_left") and velocity.x > -water_terminal_x_velocity:
				direction.x -= true_water_accel.x
			if Input.is_action_pressed("move_up") and velocity.y > -water_terminal_y_velocity:
				direction.y -= true_water_accel.y
			if Input.is_action_pressed("move_down") and velocity.y < water_terminal_y_velocity:
				direction.y += true_water_accel.y
			
			velocity *= water_friction_multiplier
		
		
		
		# Round velocity
		if velocity.x > 0:
			velocity.x = floor(velocity.x)
		else:
			velocity.x = ceil(velocity.x)
		if velocity.y > 0:
			velocity.y = floor(velocity.y)
		else:
			velocity.y = ceil(velocity.y)
		velocity += direction
		velocity = move_and_slide(velocity, Vector2.UP)
	elif freeze_movement:
		velocity = Vector2(0,0)
	elif being_attacked and in_water:
		#global_transform.origin = lerp(global_transform.origin, fake_enemy.global_transform.origin - ((fake_enemy.global_transform.origin - global_transform.origin) * 2), delta)
		#print(global_transform.origin - lerp(global_transform.origin, fake_enemy.global_transform.origin - ((fake_enemy.global_transform.origin - global_transform.origin) * 2), delta))
		velocity = global_transform.origin - lerp(global_transform.origin, fake_enemy.global_transform.origin - ((fake_enemy.global_transform.origin - global_transform.origin) * 2), delta)
		velocity = move_and_slide(velocity * -Vector2(true_water_accel.x*20, true_water_accel.y*20), Vector2.UP)
	elif being_attacked and not in_water:
		# really shit, not what I was trying to do and looks dreadful but I've stopped caring; might fix it later
		velocity = global_transform.origin - lerp(global_transform.origin, fake_enemy.global_transform.origin - ((fake_enemy.global_transform.origin - global_transform.origin) * 2), delta)
		velocity.y += land_grav
		velocity *= land_friction_multiplier
		velocity = move_and_slide(velocity, Vector2.UP)
#############################################################

# Signals #
# Ground checker
func _on_GroundChecker_body_exited(_body):
	if $GroundChecker.get_overlapping_bodies().size() == 0:
		on_ground = false
		can_jump = false
		jump_timer.stop()
func _on_GroundChecker_body_entered(_body):
	if $GroundChecker.get_overlapping_bodies().size() > 0:
		on_ground = true
		can_jump = false
		jump_timer.start()

# Water checker
func _on_WaterChecker_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	in_water = true
func _on_WaterChecker_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	in_water = false
	if Input.is_action_pressed("move_up"):
		velocity.y -= water_jumpout_velocity

# Darkness checker
func _on_DarknessChecker_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	#world_lighting_enabled = true
	in_water_starty = global_transform.origin.y
func _on_DarknessChecker_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	#world_lighting_enabled = false
	in_water_starty = null

# Oxygen checker
func _on_OxygenChecker_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	if !in_water:
		print(str(self)+": in_water == false and underwater == true; setting in_water to true.")
		in_water = true
	underwater = true
func _on_OxygenChecker_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	underwater = false

# CE checker
func _on_CaveEntranceChecker_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	get_tree().current_scene.disable_water_walls()
func _on_CaveEntranceChecker_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	get_tree().current_scene.enable_water_walls()

# Interact checkers
# Right
func _on_InteractCheckerR_body_entered(body):
	ic_checkerr_cbody = body
func _on_InteractCheckerR_body_exited(_body):
	ic_checkerr_cbody = null
# Left
func _on_InteractCheckerL_body_entered(body):
	ic_checkerl_cbody = body
func _on_InteractCheckerL_body_exited(_body):
	ic_checkerl_cbody = null

# Blackout anim checkers
func _on_BlackoutAnimator_animation_started(_anim_name):
	blackout_animating = true
func _on_BlackoutAnimator_animation_finished(_anim_name):
	blackout_animating = false


# Death timer
func _on_DeathTimer_timeout():
	dead()

# Jump timer
func _on_JumpTimer_timeout():
	can_jump = true

# Enemy try timer
func _on_EnemyTryTimer_timeout():
	try_enemy()
##########################################

# Getters / Setters #
func hide_gui():
	$Camera/UI/Control.visible = false
	freeze_movement = true
func show_gui():
	$Camera/UI/Control.visible = true
	freeze_movement = false
	can_jump = true
	on_ground = true
#####################
