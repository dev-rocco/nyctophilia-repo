extends Node2D

# Vars #
# player
export(NodePath) var player_path
# gold
export var cgold = 100
# water walls
export(NodePath) var water_walls_node
onready var water_walls = get_node(water_walls_node)
var water_walls_exist = false
###############

func _ready():
	# water walls
	loadgame(true)
	if water_walls_node:
		water_walls_exist = true

# stars
var stars = 0
func increase_stars():
	stars += 1
	if stars >= 6:
		get_tree().change_scene("res://Scenes/DevDeathScreen.tscn")
func get_stars():
	return stars

# roles
var role_dict = {0:"Swimmer",1:"Swimmer",2:"Snorkeler",3:"Snorkeler",4:"Diver",5:"Diver",6:"Aquaman",7:"Aquaman"}
func get_player_role():
	if role_dict[stars]:
		return role_dict[stars]
	else:
		return "Aquaman"


# Player
func get_player():
	return get_node(player_path)

# Gold #
func set_gold(value):
	cgold = value
func get_gold():
	return cgold
func increase_gold(value):
	cgold += value
func decrease_gold(value):
	if cgold > 0:
		cgold -= value
	if cgold < 0:
		cgold = 0
################

func disable_water_walls():
	if water_walls_exist:
		water_walls.hide()
func enable_water_walls():
	if water_walls_exist:
		water_walls.show()


## UPGRADES (very good very niiice - sexy banana) ##
var store_levels = {"oxygen":1,"oxygen_regen":1,"swim_speed":1}
export var store_bp = 50
export var store_pm = 0.5

func get_store_level(u_type):
	if u_type == "oxygen":
		return store_levels["oxygen"]
	elif u_type == "oxygen_regen":
		return store_levels["oxygen_regen"]
	elif u_type == "swim_speed":
		return store_levels["swim_speed"]
	else:
		return "NULLTYPE"

func get_store_price(u_type):
	if u_type == "oxygen" or u_type == "oxygen_regen" or u_type == "swim_speed":
		return calc_new_price(u_type)
	else:
		return "NULLTYPE"

func calc_new_price(u_type):
	return store_bp * (1 + (store_pm * get_store_level(u_type)))

func upgrade(type):
	if type is String and str(get_store_level(type)) != "NULLTYPE":
		var new_price = calc_new_price(type)
		if cgold >= new_price:
			decrease_gold(new_price)
			store_levels[type] += 1
			print(str(self)+": upgraded "+str(type)+" to level "+str(get_store_level(type))+" for $"+str(new_price))
		else:
			print(str(self)+": could not afford upgrade for $"+str(new_price))
	else:
		print(str(self)+": error: could not upgrade "+str(type)+" because upgrade type is invalid")
##################################




## Saving and loading ##
const SAVEGAME_LOC = "res://gamefiles/savegame.dat"
const AUTOSAVEGAME_LOC = "res://gamefiles/savegame.dat"
var saved_vars = [cgold, stars, store_levels, store_bp, store_pm]

func savegame(auto=false):
	var temp_f = File.new()
	if auto:
		print(str(self)+": autosaving...   FILE:\""+AUTOSAVEGAME_LOC+"\"")
		temp_f.open(AUTOSAVEGAME_LOC, File.WRITE)
		for i in saved_vars:
			temp_f.store_var(i)
	else:
		temp_f.open(SAVEGAME_LOC, File.WRITE)
		for i in saved_vars:
			temp_f.store_var(i)
	temp_f.close()

func loadgame(auto=false):
	var temp_d = Directory.new()
	var temp_f = File.new()
	if !auto and temp_d.file_exists(SAVEGAME_LOC):
		print(str(self)+": loading savegame at: "+SAVEGAME_LOC)
		temp_f.open(SAVEGAME_LOC, File.READ)
		for i in saved_vars:
			i = temp_f.get_var()
	elif auto and temp_d.file_exists(AUTOSAVEGAME_LOC):
		print(str(self)+": loading autosavegame at: "+AUTOSAVEGAME_LOC)
		temp_f.open(AUTOSAVEGAME_LOC, File.READ)
		for i in saved_vars:
			i = temp_f.get_var()
	else:
		print(str(self)+": no savegame found")
		temp_f.open(AUTOSAVEGAME_LOC, File.WRITE)
	temp_f.close()
