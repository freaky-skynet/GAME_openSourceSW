extends Control

var game_over_layer: CanvasLayer
var game_clear_layer: CanvasLayer

var boss_health_bar: ProgressBar

var game_time: float = 0.0
var is_game_active: bool = true

var clear_score_label: Label
var clear_hp_label: Label
var exit_button: Button

func _ready():
	game_over_layer = get_node_or_null("GameOverLayer") as CanvasLayer

	if game_over_layer:
		game_over_layer.hide()
	else:
		print("경고: GameOverLayer 노드를 찾을 수 없습니다.")

	# 보스 체력바 생성
	_create_boss_health_bar()

	# 클리어 화면 생성
	_create_game_clear_layer()

	# 전역 신호 연결
	GlobalGameEvents.game_over.connect(_on_game_over)
	GlobalGameEvents.game_clear.connect(_on_game_clear)
	GlobalGameEvents.boss_hp_changed.connect(_on_boss_hp_changed)

func _process(delta: float) -> void:
	if is_game_active:
		game_time += delta

func _on_game_over(score: int = -1, time_value: float = -1.0) -> void:
	is_game_active = false # 시간 측정 중지
	
	#시간기록
	var final_score = 0
	var score_manager = get_node_or_null("../ScoreManager")
	if score_manager:
		final_score = score_manager.total_score # ScoreManager에서 받아오기
		
	var final_time = game_time

	#시간,점수 결과창에 전송
	if game_over_layer:
		if game_over_layer.has_method("setup_game_over"):
			game_over_layer.setup_game_over(final_score, final_time)
		else:
			game_over_layer.show()


func _on_game_clear():
	if game_over_layer:
		game_over_layer.hide()

	if boss_health_bar:
		boss_health_bar.hide()

	clear_score_label.text = "SCORE : " + str(GlobalGameEvents.current_score)
	clear_hp_label.text = "HP : " + str(GlobalGameEvents.current_player_hp)

	game_clear_layer.show()

	# 클리어 후 게임 멈춤
	get_tree().paused = true


# 보스 체력바 생성
func _create_boss_health_bar() -> void:
	boss_health_bar = ProgressBar.new()
	boss_health_bar.name = "BossHealthBar"

	boss_health_bar.min_value = 0
	boss_health_bar.max_value = 100
	boss_health_bar.value = 100
	boss_health_bar.show_percentage = true

	boss_health_bar.position = Vector2(90, 20)
	boss_health_bar.size = Vector2(300, 24)

	add_child(boss_health_bar)

	print("보스 체력바 생성됨")


# 보스 체력바 갱신
func _on_boss_hp_changed(current_hp: int, max_hp: int) -> void:
	print("보스 체력바 갱신:", current_hp, "/", max_hp)

	if not boss_health_bar:
		return

	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp

	if current_hp <= 0:
		boss_health_bar.hide()
	else:
		boss_health_bar.show()


# 게임 클리어 화면 생성
func _create_game_clear_layer() -> void:
	game_clear_layer = CanvasLayer.new()
	game_clear_layer.name = "GameClearLayer"
	game_clear_layer.hide()

	# 게임이 pause 되어도 버튼이 작동하도록 설정
	game_clear_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	add_child(game_clear_layer)

	var background := ColorRect.new()
	background.color = Color(0, 0, 0, 0.75)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	game_clear_layer.add_child(background)

	var panel := ColorRect.new()
	panel.color = Color(0.05, 0.05, 0.05, 1.0)
	panel.position = Vector2(140, 220)
	panel.size = Vector2(200, 180)
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	game_clear_layer.add_child(panel)

	var title_label := Label.new()
	title_label.text = "GAME CLEAR"
	title_label.position = Vector2(45, 20)
	title_label.size = Vector2(110, 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_child(title_label)

	clear_score_label = Label.new()
	clear_score_label.text = "SCORE : 0"
	clear_score_label.position = Vector2(40, 65)
	clear_score_label.size = Vector2(120, 25)
	clear_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_score_label.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_child(clear_score_label)

	clear_hp_label = Label.new()
	clear_hp_label.text = "HP : 0"
	clear_hp_label.position = Vector2(40, 95)
	clear_hp_label.size = Vector2(120, 25)
	clear_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_hp_label.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_child(clear_hp_label)

	exit_button = Button.new()
	exit_button.text = "EXIT"
	exit_button.position = Vector2(60, 130)
	exit_button.size = Vector2(80, 30)
	exit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	exit_button.pressed.connect(_on_exit_pressed)
	panel.add_child(exit_button)


func _on_exit_pressed():
	get_tree().paused = false
	get_tree().quit()
