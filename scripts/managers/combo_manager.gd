extends Control

@onready var combo_timer: Timer = $ComboTimer
#@onready var combo_label: Label = get_node_or_null("Label") as Label
#@onready var combo_inner_label: Label = get_node_or_null("Label/Label") as Label
@onready var combo_bar: TextureProgressBar = $TextureProgressBar

var combo_counter:int = 0
var combo_level:int = 1

# 폰트 강제적용
var combo_font: Font = preload("res://assets/images/UI/font/neodgm.ttf")
# ComboControl 아래에 있는 모든 Label을 저장
var combo_labels: Array[Label] = []

func _ready():
	GlobalGameEvents.player_hit_enemy.connect(_on_enemy_hit)

	combo_bar.max_value=100
	combo_bar.value=combo_bar.max_value
	
	_find_combo_labels()
	_apply_combo_label_style()
	
	update_combo_ui()
	
# ComboControl 아래의 모든 Label 찾기
func _find_combo_labels() -> void:
	combo_labels.clear()

	for node in find_children("*", "Label", true, false):
		var label := node as Label

		if label:
			combo_labels.append(label)
			print("콤보 Label 찾음: ", label.get_path())

# 찾은 모든 Label에 폰트 / 크기 / 색 강제 적용
func _apply_combo_label_style() -> void:
	for label in combo_labels:
		var settings := LabelSettings.new()
		settings.font = combo_font
		settings.font_size = 48
		settings.font_color = Color.WHITE
		settings.outline_size = 7
		settings.outline_color = Color.BLACK

		label.label_settings = settings
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		
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
			
		_set_combo_outline(12, Color(0.0, 0.816, 0.816, 1.0))
	
	update_combo_ui()
	combo_timer.start()

func _on_combo_timer_timeout():
	combo_counter = 0
	combo_level = 1
	
	_set_combo_outline(7, Color(1, 1, 1, 1))
	
	GlobalGameEvents.combo_level=1
	update_combo_ui()
	print("TOO BAD! combo restart")

func _set_combo_outline(size: int, color: Color) -> void:
	for label in combo_labels:
		if label.label_settings:
			label.label_settings.outline_size = size
			label.label_settings.outline_color = color


func update_combo_ui():
	if combo_counter > 0:
		for label in combo_labels:
			label.text = "%03d" % combo_counter
			label.visible = true

		combo_bar.visible = true
	else:
		for label in combo_labels:
			label.visible = false

		combo_bar.visible = false
