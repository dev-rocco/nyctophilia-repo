extends Sprite

var rng = RandomNumberGenerator.new()
var rng2 = RandomNumberGenerator.new()
var attacking = false
onready var attacking_period_timer = $AttackingPeriodTimer
onready var attack_sound_player = $AttackSoundPlayer
onready var cscene = get_tree().current_scene

func _ready():
	rng.randomize()
	rng2.randomize()

func attack():
	attacking = true
	attacking_period_timer.start()
	var attack_point = rng2.randi_range(1,4)
	global_transform.origin = cscene.get_player().get_node("EnemySpawnLocs/EnemySpawn"+str(attack_point)).global_transform.origin
	attack_sound_player.play()

func _process(delta):
	if attacking:
		if !visible:
			visible = true
		global_transform.origin = lerp(global_transform.origin, cscene.get_player().global_transform.origin, 2 * delta)
	if !attacking and visible:
		visible = false

func get_lerped_dir(delta):
	return lerp(global_transform.origin, cscene.get_player().global_transform.origin, delta)

# 1 in 10 chance
func decide_attack():
	print("deciding attack")
	var decision_number = rng.randi_range(1,10)
	# 4 is arbitrary
	if decision_number == 4:
		attack()

func get_attacking():
	return attacking

func _on_AttackingPeriodTimer_timeout():
	attacking = false
