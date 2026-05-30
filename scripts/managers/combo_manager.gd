extends Control

@onready var combo_timer=$ComboTimer
@onready var combo_label=$Label
@onready var combo_bar=$TextureProgressBar
var combo_counter:int = 0
var combo_level:int = 1

func _ready():
	GlobalGameEvents.player_hit_enemy.connect(_on_enemy_hit)

	combo_bar.max_value=100
	combo_bar.value=combo_bar.max_value
	update_combo_ui()

func _process(float):
	combo_bar.value=combo_timer.time_left*100

func _on_enemy_hit(_dmg):
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
			combo_label.label_settings.outline_size=12
			combo_label.label_settings.outline_color=Color(0,0.97,0.97,1)
	update_combo_ui()
	combo_timer.start()

func _on_combo_timer_timeout():
	combo_counter = 0
	combo_level = 1
	combo_label.label_settings.outline_size=7
	combo_label.label_settings.outline_color=Color(1,1,1,1)
	GlobalGameEvents.combo_level=1
	update_combo_ui()
	print("TOO BAD! combo restart")

func update_combo_ui():
	if combo_counter>0:
		combo_label.text = "%d" % combo_counter
		combo_label.visible = true
		combo_bar.visible = true
	else:
		combo_label.visible = false
		combo_bar.visible = false
