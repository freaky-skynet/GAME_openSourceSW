extends Control

var game_over_layer: CanvasLayer
var game_clear_layer: CanvasLayer
var boss_health_bar: ProgressBar


func _ready() -> void:
	game_over_layer = get_node_or_null("GameOverLayer") as CanvasLayer

	if game_over_layer:
		game_over_layer.hide()
	else:
		print("경고: GameOverLayer 노드를 찾을 수 없습니다! 경로를 확인하세요.")

	_create_boss_health_bar()
	_create_game_clear_layer()

	GlobalGameEvents.game_over.connect(_on_game_over)
	GlobalGameEvents.game_clear.connect(_on_game_clear)
	GlobalGameEvents.boss_hp_changed.connect(_on_boss_hp_changed)


func _create_boss_health_bar() -> void:
	var existing_bar := get_node_or_null("BossHealthBar") as ProgressBar

	if existing_bar:
		boss_health_bar = existing_bar
		return

	boss_health_bar = ProgressBar.new()
	boss_health_bar.name = "BossHealthBar"

	boss_health_bar.min_value = 0
	boss_health_bar.max_value = 100
	boss_health_bar.value = 100
	boss_health_bar.show_percentage = true

	boss_health_bar.position = Vector2(90, 20)
	boss_health_bar.size = Vector2(300, 24)

	add_child(boss_health_bar)


func _create_game_clear_layer() -> void:
	var existing_layer := get_node_or_null("GameClearLayer") as CanvasLayer

	if existing_layer:
		game_clear_layer = existing_layer
		game_clear_layer.hide()
		return

	game_clear_layer = CanvasLayer.new()
	game_clear_layer.name = "GameClearLayer"

	add_child(game_clear_layer)

	var background := ColorRect.new()
	background.name = "ColorRect"
	background.color = Color(0, 0, 0, 1)

	background.anchor_left = 0.5
	background.anchor_top = 0.5
	background.anchor_right = 0.5
	background.anchor_bottom = 0.5

	background.offset_left = -75.0
	background.offset_top = -40.0
	background.offset_right = 75.0
	background.offset_bottom = 40.0

	game_clear_layer.add_child(background)

	var label := Label.new()
	label.name = "Label"
	label.text = "GAME CLEAR"

	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5

	label.offset_left = -55.0
	label.offset_top = -12.0
	label.offset_right = 55.0
	label.offset_bottom = 12.0

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	game_clear_layer.add_child(label)

	game_clear_layer.hide()


func _on_game_over() -> void:
	if game_over_layer:
		game_over_layer.show()


func _on_game_clear() -> void:
	if game_over_layer:
		game_over_layer.hide()

	if game_clear_layer:
		game_clear_layer.show()


func _on_boss_hp_changed(current_hp: int, max_hp: int) -> void:
	if not boss_health_bar:
		return

	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp

	if current_hp <= 0:
		boss_health_bar.hide()
	else:
		boss_health_bar.show()
