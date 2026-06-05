extends Control

var game_over_layer: CanvasLayer

# 기존 game_clear_layer를 게임오버/게임클리어 공용 결과창으로 사용
var game_clear_layer: CanvasLayer

var boss_health_bar: ProgressBar
var boss_health_fill_style: StyleBoxFlat

var game_time: float = 0.0
var is_game_active: bool = true

var result_title_label: Label
var clear_score_label: Label
var clear_hp_label: Label
var clear_time_label: Label
var ranking_label: Label

var restart_button: Button
var exit_button: Button

var result_font: Font = preload("res://assets/neodgm.ttf")


func _ready():
	game_over_layer = get_node_or_null("GameOverLayer") as CanvasLayer

	if game_over_layer == null:
		game_over_layer = get_node_or_null("../GameOverLayer") as CanvasLayer

	if game_over_layer:
		game_over_layer.hide()
	else:
		print("경고: GameOverLayer 노드를 찾을 수 없습니다.")

	# 보스 체력바 생성
	_create_boss_health_bar()

	# 공용 결과창 생성
	_create_game_clear_layer()

	# 전역 신호 연결
	GlobalGameEvents.game_over.connect(_on_game_over)
	GlobalGameEvents.game_clear.connect(_on_game_clear)
	GlobalGameEvents.boss_hp_changed.connect(_on_boss_hp_changed)


func _process(delta: float) -> void:
	if is_game_active:
		game_time += delta


func _on_game_over(score: int = -1, time_value: float = -1.0) -> void:
	if not is_game_active: return

	is_game_active = false

	var final_score := 0

	if score != -1:
		final_score = score
	else:
		var score_manager = get_node_or_null("../ScoreManager")
		if score_manager:
			final_score = score_manager.total_score

	var final_time := game_time

	if time_value >= 0.0:
		final_time = time_value

	# 게임오버 기록도 랭킹에 저장
	_save_result_to_ranking(final_score, final_time, "DEAD")

	# 공용 결과창만 사용하도록 코드 수정함!
	if game_over_layer:
		game_over_layer.hide()

	_show_result_screen("GAME OVER", final_score, GlobalGameEvents.current_player_hp, final_time)

	# 게임오버 후 게임 멈춤
	get_tree().paused = true


func _on_game_clear():
	if not is_game_active: return

	is_game_active = false

	var final_score: int = GlobalGameEvents.current_score
	var final_time := game_time

	# 클리어 기록 랭킹 저장
	_save_result_to_ranking(final_score, final_time, "CLEAR")

	if game_over_layer:
		game_over_layer.hide()

	_show_result_screen("GAME CLEAR", final_score, GlobalGameEvents.current_player_hp, final_time)
	get_tree().paused = true


# 보스 체력바 생성
func _create_boss_health_bar() -> void:
	boss_health_bar = ProgressBar.new()
	boss_health_bar.name = "BossHealthBar"

	boss_health_bar.min_value = 0
	boss_health_bar.max_value = 100
	boss_health_bar.value = 100
	boss_health_bar.show_percentage = true

	boss_health_bar.position = Vector2(150, 12)
	boss_health_bar.size = Vector2(310, 24)
	
	# 배경 스타일
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color(0.08, 0.08, 0.08, 0.9)
	background_style.border_color = Color(1.0, 1.0, 1.0, 0.8)
	background_style.set_border_width_all(2)
	background_style.set_corner_radius_all(4)
	
	# 체력 채워지는 부분 스타일
	boss_health_fill_style = StyleBoxFlat.new()
	boss_health_fill_style.bg_color = Color(1.0, 0.9, 0.1, 1.0) # 처음은 노란색
	boss_health_fill_style.set_corner_radius_all(4)

	
	# ProgressBar에 스타일 적용
	boss_health_bar.add_theme_stylebox_override("background", background_style)
	boss_health_bar.add_theme_stylebox_override("fill", boss_health_fill_style)
	# 퍼센트 글자 색 / 크기 / 외곽선
	boss_health_bar.add_theme_color_override("font_color", Color.WHITE)
	boss_health_bar.add_theme_color_override("font_outline_color", Color.BLACK)
	boss_health_bar.add_theme_constant_override("outline_size", 4)
	boss_health_bar.add_theme_font_size_override("font_size", 18)
	
	# 폰트
	var boss_font := load("res://assets/neodgm.ttf")
	boss_health_bar.add_theme_font_override("font", boss_font)

	add_child(boss_health_bar)

	print("보스 체력바 생성됨")


# 보스 체력바 갱신
func _on_boss_hp_changed(current_hp: int, max_hp: int) -> void:
	print("보스 체력바 갱신:", current_hp, "/", max_hp)

	if not boss_health_bar:
		return

	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp

	# 보스 체력 비율 계산
	var hp_percent := float(current_hp) / float(max_hp) * 100.0

	# 체력 비율에 따라 색 변경
	if boss_health_fill_style:
		if hp_percent <= 30.0:
			boss_health_fill_style.bg_color = Color(1.0, 0.05, 0.02, 1.0) # 빨간색
		elif hp_percent <= 65.0:
			boss_health_fill_style.bg_color = Color(1.0, 0.45, 0.0, 1.0) # 주황색
		else:
			boss_health_fill_style.bg_color = Color(1.0, 0.9, 0.1, 1.0) # 노란색

	if current_hp <= 0:
		boss_health_bar.hide()
	else:
		boss_health_bar.show()

func _style_result_label(label: Label, font_size: int, font_color: Color, outline_size: int = 2) -> void:
	label.add_theme_font_override("font", result_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", outline_size)


func _style_result_button(button: Button) -> void:
	button.add_theme_font_override("font", result_font)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color.WHITE)


# 게임오버/게임클리어 공용 결과창
func _create_game_clear_layer() -> void:
	game_clear_layer = CanvasLayer.new()
	game_clear_layer.name = "GameResultLayer"
	game_clear_layer.layer = 100
	game_clear_layer.hide()

	# pause 상태에서도 버튼이 작동하도록 설정
	game_clear_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	add_child(game_clear_layer)

	# 어두운 배경
	var background := ColorRect.new()
	background.color = Color(0, 0, 0, 0.68)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_clear_layer.add_child(background)

	# 중앙 패널zzzzzzzzzzzzzzzzzzzzz
	var panel := ColorRect.new()
	panel.name = "ResultPanel"
	panel.color = Color(0.04, 0.04, 0.04, 0.94)
	panel.size = Vector2(360, 420)
	panel.process_mode = Node.PROCESS_MODE_ALWAYS

	var viewport_size := get_viewport_rect().size
	panel.position = Vector2(
		(viewport_size.x - panel.size.x) / 2.0,
		(viewport_size.y - panel.size.y) / 2.0
	)

	game_clear_layer.add_child(panel)

	# 내부 자동 정렬 컨테이너
	var content := VBoxContainer.new()
	content.name = "ResultContent"
	content.position = Vector2(26, 24)
	content.size = Vector2(panel.size.x - 52, panel.size.y - 48)
	content.alignment = BoxContainer.ALIGNMENT_BEGIN
	content.add_theme_constant_override("separation", 8)
	content.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_child(content)

	# 결과 제목
	result_title_label = Label.new()
	result_title_label.text = "GAME RESULT"
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_title_label.custom_minimum_size = Vector2(0, 34)
	result_title_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(result_title_label, 30, Color(1.0, 0.9, 0.1, 1.0), 4) # 제목 노란색
	content.add_child(result_title_label)

	# 점수
	clear_score_label = Label.new()
	clear_score_label.text = "SCORE : 0"
	clear_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_score_label.custom_minimum_size = Vector2(0, 26)
	clear_score_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(clear_score_label, 18, Color.WHITE, 2) # 추가
	content.add_child(clear_score_label)

	# HP
	clear_hp_label = Label.new()
	clear_hp_label.text = "HP : 0"
	clear_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_hp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_hp_label.custom_minimum_size = Vector2(0, 26)
	clear_hp_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(clear_hp_label, 18, Color.WHITE, 2) # 추가
	content.add_child(clear_hp_label)

	# 시간
	clear_time_label = Label.new()
	clear_time_label.text = "TIME : 00:00.00"
	clear_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_time_label.custom_minimum_size = Vector2(0, 26)
	clear_time_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(clear_time_label, 18, Color.WHITE, 2) # 추가
	content.add_child(clear_time_label)

	# 랭킹 제목
	var ranking_title_label := Label.new()
	ranking_title_label.text = "[ 랭킹 TOP 5 ]"
	ranking_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_title_label.custom_minimum_size = Vector2(0, 30)
	ranking_title_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(ranking_title_label, 18, Color(1.0, 0.9, 0.1, 1.0), 2)
	content.add_child(ranking_title_label)

	# 랭킹 내용
	ranking_label = Label.new()
	ranking_label.text = "랭킹 기록 없음"
	ranking_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ranking_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	ranking_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_label.custom_minimum_size = Vector2(0, 145)
	ranking_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	ranking_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_result_label(ranking_label, 14, Color(0.85, 0.95, 1.0, 1.0), 1)
	content.add_child(ranking_label)

	# 버튼 행
	var button_row := HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 18)
	button_row.custom_minimum_size = Vector2(0, 42)
	button_row.process_mode = Node.PROCESS_MODE_ALWAYS
	content.add_child(button_row)

	# 재시작 버튼
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(105, 36)
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.focus_mode = Control.FOCUS_NONE
	_style_result_button(restart_button)
	restart_button.pressed.connect(_on_restart_pressed)
	button_row.add_child(restart_button)

	# 종료 버튼
	exit_button = Button.new()
	exit_button.text = "EXIT"
	exit_button.custom_minimum_size = Vector2(105, 36)
	exit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	exit_button.focus_mode = Control.FOCUS_NONE
	_style_result_button(exit_button)
	exit_button.pressed.connect(_on_exit_pressed)
	button_row.add_child(exit_button)


# 결과 표시 함수
func _show_result_screen(result_title: String, final_score: int, final_hp: int, final_time: float) -> void:
	if boss_health_bar:
		boss_health_bar.hide()

	if game_clear_layer == null:
		return

	result_title_label.text = result_title
	if result_title == "GAME OVER":
		result_title_label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.1, 1.0))
	else:
		result_title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1, 1.0))
	clear_score_label.text = "SCORE : " + str(final_score)
	clear_hp_label.text = "HP : " + str(final_hp)
	clear_time_label.text = "TIME : " + _format_time(final_time)
	ranking_label.text = _get_ranking_text()

	game_clear_layer.show()


# 랭킹 저장
func _save_result_to_ranking(score: int, clear_time: float, result_type: String) -> void:
	var ranking_manager = get_node_or_null("/root/RankingManager")

	if ranking_manager == null:
		print("경고: RankingManager AutoLoad를 찾을 수 없습니다.")
		return

	var finished_at := Time.get_datetime_string_from_system(false, true)

	if ranking_manager.has_method("add_record"):
		ranking_manager.add_record(score, clear_time, finished_at, result_type)
	else:
		print("경고: RankingManager에 add_record 함수가 없습니다.")


# 랭킹 텍스트 가져오기
func _get_ranking_text() -> String:
	var ranking_manager = get_node_or_null("/root/RankingManager")

	if ranking_manager == null:
		return "랭킹 매니저 없음"

	if not ranking_manager.has_method("get_ranking_text"):
		return "랭킹 출력 함수 없음"

	var text := str(ranking_manager.get_ranking_text())
	text = text.replace("[ 랭킹 TOP 5 ]", "")
	text = text.strip_edges()

	#보정넣기
	text = text.replace("CLEAR", " CLEAR")
	text = text.replace("DEAD", " DEAD")
	text = text.replace("  CLEAR", " CLEAR")
	text = text.replace("  DEAD", " DEAD")

	if text.is_empty():
		return "랭킹 기록 없음"

	return text


# 시간 표시 형식
func _format_time(time_sec: float) -> String:
	var total_sec := int(time_sec)
	var minutes := int(total_sec / 60)
	var seconds := total_sec % 60
	var milliseconds := int((time_sec - total_sec) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


# 현재 게임 씬 재시작
func _on_restart_pressed():
	get_tree().paused = false
	GlobalGameEvents.combo_level = 1 #버그 수정 끝나는 경우 콤보 초기화
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().quit()
