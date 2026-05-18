extends Control

@onready var combo_timer=$ComboTimer
var combo_counter:int = 0
var combo_level:int = 1

func _ready():
	GlobalGameEvents.player_hit_enemy.connect(_on_enemy_hit)

func _on_enemy_hit(dmg):
	combo_counter += 1 # 콤보 상승!
	print(combo_counter,": combo, wombo combo!!")
	#if combo_counter > 5:
	#한번만 emit하도록 바꾸자..
	if combo_level < 2:
		if combo_counter>=5 and combo_counter<10:
			combo_level=2
			GlobalGameEvents.combo_level=2
			print("LEVEL 2!!")
	if combo_level < 3:
		if combo_counter>=10:
			combo_level=3
			GlobalGameEvents.combo_level=3
			print("LEVEL 3!!")
	combo_timer.start()

func _on_combo_timer_timeout():
	combo_counter = 0
	combo_level = 1
	GlobalGameEvents.combo_level=1
	print("TOO BAD! combo restart")
