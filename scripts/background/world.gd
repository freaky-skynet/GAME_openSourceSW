extends Node2D

@onready var planet_layer: Node2D = $PlanetLayer
@onready var countdown_layer: CanvasLayer = $CountdownLayer
@onready var countdown_label: Label = $CountdownLayer/CountdownLabel


func _ready() -> void:
	_connect_boss_phase_signal()

	await _play_start_countdown()


func _play_start_countdown() -> void:
	get_tree().paused = true # 게임 잠깐 멈추기

	countdown_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	countdown_label.process_mode = Node.PROCESS_MODE_ALWAYS

	countdown_layer.visible = true

	countdown_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	countdown_label.text = "3"
	await get_tree().create_timer(1.0, true).timeout

	countdown_label.text = "2"
	await get_tree().create_timer(1.0, true).timeout

	countdown_label.text = "1"
	await get_tree().create_timer(1.0, true).timeout

	countdown_label.text = "GO!"
	await get_tree().create_timer(0.5, true).timeout

	countdown_layer.visible = false

	get_tree().paused = false


func _connect_boss_phase_signal() -> void:
	var boss = get_tree().get_first_node_in_group("boss")

	if boss == null:
		print("boss 그룹에 들어간 보스를 찾지 못함")
		return

	if boss.has_signal("phase_changed"):
		boss.connect("phase_changed", Callable(self, "_on_boss_phase_changed"))
	else:
		print("현재 찾은 boss 노드에 phase_changed 신호가 없음: ", boss.name)


func _on_boss_phase_changed(new_phase: int) -> void:
	planet_layer.change_phase(new_phase)
