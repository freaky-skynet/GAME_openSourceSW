extends CharacterBody2D

signal phase_changed(new_phase: int)

@export var max_hp: int = 1000
@export var hit_flash_time: float = 0.08
@export var clear_score: int = 3000 #클리어시 추가되는 점수
@export var pattern_time:float = 3.0 #한 패턴의 지속시간
@export var pattern_rest_time: float = 0.5 #1.0 # 0.5 #패턴 사이사이 쉬는 시간 
@export var fire_time:float = 0.1

#보스 이펙트용
@export var phase_transition_time: float = 0.6
@export var outer_shield_radius: float = 123.0
@export var inner_shield_radius: float = 110.0
@export var shield_ring_width: float = 4.0
@export var shield_escape_time: float = 0.8
@export var shield_escape_margin: float = 120.0
@export var shield_ring_point_count: int = 96 

var is_invincible: bool = false
var is_phase_transitioning: bool = false 
var pattern_run_id: int = 0 
@export var phase_invincible_extra_time: float = 1.0

@onready var boss_bullet_manager = %BossBulletManager
@onready var fire_timer: Timer = $FireTimer#총알 발사간격
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pattern_timer: Timer = $PatternTimer
#5.26 패턴 작동방식을 AUTOSTART되는 타이머가 TIMEOUT될때마다 호출하는식으로 바꿈


var current_hp: int = 100
var current_phase=1
var phase_point1:int=0
var phase_point2:int=0

var pattern_num:int = 0
var pos: Vector2 = Vector2.ZERO
var variation: float = 0.0#공격패턴 변화 인수
var is_dead: bool = false
var is_p3_aiming: bool = false#3페이즈 기관총

# 3페이즈 상태 관리 및 이동용 변수
enum P3State { DRIFTING, DASHING } # 산책 모드와 돌진 모드
var current_p3_state: P3State = P3State.DRIFTING

@export var p3_normal_speed: float = 150.0 # 산책 속도
@export var p3_dash_speed: float = 500.0   # 돌진 속도
var p3_target_pos: Vector2 = Vector2.ZERO
var p3_is_waiting: bool = false

var min_x: float = 75.0
var max_x: float = 405.0
var min_y: float = 75.0
var max_y: float = 210.0

#  둥둥 효과 변수
@export var float_amplitude: float = 10.0
@export var float_speed: float = 3.0
var time_passed: float = 0.0
var base_position: Vector2               # 이동 계산용 뼈대 위치


func _on_ready() -> void:
	base_position = global_position
	current_hp = max_hp
	fire_timer.wait_time=fire_time
	#pattern_timer가 다 탔을때마다 패턴 발사하도록 설정
	pattern_timer.timeout.connect(boss_attack)
	
	GlobalGameEvents.boss_hp_changed.connect(phase_manager)
	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)
	
	phase_point1 = int(max_hp*0.65)
	phase_point2 = int(max_hp*0.3)
	
	_update_phase_sprite(current_phase)
	
	
	await get_tree().create_timer(4).timeout
	boss_attack()
	
func _process(delta: float) -> void:
	# 1. 둥둥 떠다니는 효과
	time_passed += delta
	var float_offset = sin(time_passed * float_speed) * float_amplitude
	
	# 2. 3페이즈 이동 상태 제어
	if current_phase == 3 and not is_dead and not is_phase_transitioning:
		if current_p3_state == P3State.DRIFTING:
			_process_p3_drift(delta)
		elif current_p3_state == P3State.DASHING:
			_process_p3_dash(delta)
			
	# 3. 최종 위치 적용 (뼈대 위치 + 둥둥 효과)
	global_position = Vector2(base_position.x, base_position.y + float_offset)
	
	# 4. 탄환 매니저가 사용할 발사 위치(pos) 갱신
	pos = global_position
	
func phase_manager(current_hp:int,_max_hp:int)->void:
	#현재 체력에 따라 페이즈를 바꿈 
	#print(phase_point1," ",phase_point2," ",current_hp)
	var before_phase: int = current_phase
	
	if (phase_point2 <= current_hp && current_hp <= phase_point1):
		current_phase=2
		print("PHASE2")
	elif (current_hp < phase_point2):
		current_phase=3
		print("PHASE3")
		
	if before_phase != current_phase:
		print("PHASE", current_phase)
		
		if current_phase == 3:
			current_p3_state = P3State.DRIFTING
			_set_new_p3_random_target()
			
		_start_phase_transition(before_phase, current_phase)
		phase_changed.emit(current_phase)
	
func boss_attack():
	#페이즈 따라 패턴 바꿔가며 공격
	#5.26: while문 안에 타이머 넣으면 프레임마다 실행되는 반복문으로 인해 게임 터짐;ㅈㅅㅈㅅ!!
	
	#보스 페이즈 변경시 멈춤
	if is_dead or is_phase_transitioning:
		return
	pattern_run_id += 1
	
	
	# 새 패턴 시작 시 이전에 남아있던 패턴 무효화
	# 페이즈가 바뀔 때만 _cancel_current_pattern()으로 run_id가 증가함
	var run_id := pattern_run_id
	var attack_phase: int = current_phase
	
	pattern_random()#페이즈 넘버를 랜덤으로 뽑는 함수
	match attack_phase:
		1:
			phase1_pattern_fire(run_id)
		2:
			phase2_pattern_fire(run_id)
		3:
			phase3_pattern_fire(run_id)

	variation = 0
			
		
func pattern_random():#같은 숫자가 안나올때까지 주사위를 굴리는 함수입니다
	var temp:int = pattern_num
	pattern_num=randi_range(1,3)
	while (pattern_num==temp):
		pattern_num=randi_range(1,3)

func phase1_pattern_fire(run_id: int) -> void:
	match pattern_num:
		1:
			await p1_pattern1(run_id)
		2:
			await p1_pattern2(run_id)
		3:
			await p1_pattern3(run_id)

# 2페이즈
func phase2_pattern_fire(run_id: int) -> void:
	for i in range(23):
		
		if _is_pattern_cancelled(run_id, 2):# 겹침 해결용
			return
			
		fire_timer.start()
		await fire_timer.timeout
	
		if _is_pattern_cancelled(run_id, 2):
			return
		
		match pattern_num:
			1:
				p2_pattern1()
			2:
				p2_pattern2()
			3:
				p2_pattern3()


# 3페이즈
func phase3_pattern_fire(run_id: int) -> void:
	if _is_pattern_cancelled(run_id, 3):
		return
	
	current_p3_state = P3State.DASHING
	p3_is_waiting = false
	_set_new_p3_random_target()

	match pattern_num:
		1:
			p3_pattern1(run_id)
		2:
			p3_pattern2(run_id)
		3:
			p3_pattern3(run_id)



func p1_pattern1(run_id: int) -> void:#페이즈1 패턴1, 흩뿌리기
	if _is_pattern_cancelled(run_id, 1):#겹침 해결용
		return
	if is_dead:
		return
	variation=0.0
	for i in range(25):
		if _is_pattern_cancelled(run_id, 1):
			return
		fire_timer.start()
		await fire_timer.timeout
		if _is_pattern_cancelled(run_id, 1):
			return
		boss_bullet_manager.fire_p1_pattern1_radial(pos, variation)
		variation += 1.5

func p1_pattern2(run_id: int) -> void:#페이즈1패턴2 일시유도탄
	
	if _is_pattern_cancelled(run_id, 1):
		return
	if is_dead:
		return
	for i in range(3):
		if _is_pattern_cancelled(run_id, 1):
			return

		boss_bullet_manager.fire_p1_pattern2_follow(pos)

		await get_tree().create_timer(1.5).timeout

		if _is_pattern_cancelled(run_id, 1):
			return

func p1_pattern3(run_id: int) -> void:#페이즈3패턴3 낙뢰
	
	if _is_pattern_cancelled(run_id, 1):
		return
	if is_dead:
		return
	for i in range(4):
		if _is_pattern_cancelled(run_id, 1):
			return

		boss_bullet_manager.fire_p1_pattern3_shunrai()

		await get_tree().create_timer(1.5).timeout

		if _is_pattern_cancelled(run_id, 1):
			return

# 랜덤으로 3개 패턴 중 하나를 골라서 실행
func p2_pattern1() -> void:
	if is_dead:
		return

	print("phase2 pattern1")
	boss_bullet_manager.fire_p2_rotating_radial(pos, variation)
	variation += 0.25


func p2_pattern2() -> void:
	if is_dead:
		return

	# print("player group nodes: ", get_tree().get_nodes_in_group("player"))
	var player = get_tree().get_first_node_in_group("player")

	if player:
		boss_bullet_manager.fire_p2_aimed_spread(pos, player.global_position)
		print("phase2 pattern2 player confirmed")
	else:
		boss_bullet_manager.fire_p2_rotating_radial(pos, variation)


func p2_pattern3() -> void:
	if is_dead:
		return
		
	print("phase2 pattern3")

	boss_bullet_manager.fire_p2_cross_spread(pos, variation)
	variation += 0.35


func p3_pattern1(run_id: int) -> void:
	for burst in range(3):
		if _is_pattern_cancelled(run_id, 3): return
		
		var locked_target_pos: Vector2 = Vector2.ZERO
		var player = get_tree().get_first_node_in_group("player")
		
		if player:
			locked_target_pos = player.global_position
		else:
			return

		for i in range(3):
			if _is_pattern_cancelled(run_id, 3): return
			
			boss_bullet_manager.fire_p3_aimed(pos, locked_target_pos)
			
			await get_tree().create_timer(0.1).timeout
		
		if _is_pattern_cancelled(run_id, 3): return
		await get_tree().create_timer(0.4).timeout



func p3_pattern2(run_id: int) -> void:
	for i in range(25):
		if _is_pattern_cancelled(run_id, 3): return
		for multi in range(3):
			boss_bullet_manager.fire_p3_chaos_gatling(pos)
			await get_tree().create_timer(0.02).timeout
		fire_timer.start()
		await fire_timer.timeout



func p3_pattern3(run_id: int) -> void:
	for i in range(25):
		if _is_pattern_cancelled(run_id, 3): return
		
		# 사방 난사
		for multi in range(3):
			boss_bullet_manager.fire_p3_chaos_gatling(pos)
			await get_tree().create_timer(0.02).timeout
		
		# 주기적으로 플레이어 조준 콤보 섞기
		if i % 5 < 3:
			var player = get_tree().get_first_node_in_group("player")
			if player:
				for multi in range(3):
					boss_bullet_manager.fire_p3_aimed(pos, player.global_position)
					await get_tree().create_timer(0.04).timeout
					
		fire_timer.start()
		await fire_timer.timeout

func take_damage(amount: int) -> void:
	if is_dead:
		return

	if is_invincible:
		print("페이즈 전환 중 무적")
		return

	if amount <= 0:
		return

	current_hp -= amount
	current_hp = max(current_hp, 0)

	print("보스 현재 체력: ", current_hp, "/", max_hp)

	# 체력이 변할 때마다 UI에 전달
	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)

	_flash_hit()

	if current_hp <= 0:
		die()


func _flash_hit() -> void:
	if not sprite:
		return

	sprite.modulate = Color(1.0, 0.35, 0.35)

	await get_tree().create_timer(hit_flash_time).timeout

	if not is_dead and sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0)

func _update_phase_sprite(new_phase: int) -> void: #보스스프라이트 업데이트용
	if not sprite:
		return

	var animation_name := ""

	match new_phase:
		1:
			animation_name = "phase1"
		2:
			animation_name = "phase2"
		3:
			animation_name = "phase3"
		_:
			animation_name = "phase1"

	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
	else:
		print("보스 페이즈 스프라이트를 찾을 수 없음: ", animation_name)

#보스 페이즈 애니매이션
func _start_phase_transition(old_phase: int, new_phase: int) -> void:
	if is_phase_transitioning: return

	is_phase_transitioning = true
	is_invincible = true
	_cancel_current_pattern()
	
	if pattern_timer: pattern_timer.stop()
	if fire_timer: fire_timer.stop()

	var break_radii: Array[float] = []
	if old_phase == 1 and new_phase >= 2: break_radii.append(outer_shield_radius)
	if old_phase <= 2 and new_phase >= 3: break_radii.append(inner_shield_radius)
 
	_update_phase_sprite(new_phase)
	await _play_shield_break_effect(break_radii)
	
	if new_phase == 3:
		await _play_p3_rage_and_burst()
	await get_tree().create_timer(phase_invincible_extra_time).timeout

	is_invincible = false
	is_phase_transitioning = false

	if not is_dead:
		if pattern_timer:
			pattern_timer.stop()
			pattern_timer.start()
		boss_attack.call_deferred()

#보스 보호막 파괴 효과 
func _play_shield_break_effect(radii: Array[float]) -> void:
	if radii.is_empty():
		return

	var ring_data: Array = []

	for radius in radii:
		var ring := _create_shield_ring(radius)
		add_child(ring)

		ring_data.append({
			"ring": ring,
			"radius": radius
		})

	# 보스 본체가 잠깐 붉게 깜빡임
	for i in range(3):
		if sprite:
			sprite.modulate = Color(1.0, 0.25, 0.25, 1.0)

		await get_tree().create_timer(0.06).timeout

		if sprite:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

		await get_tree().create_timer(0.06).timeout

	var tween := create_tween()
	tween.set_parallel(true)

	for data in ring_data:
		var ring: Line2D = data["ring"]
		var radius: float = data["radius"]

		var target_scale := _get_ring_escape_scale(radius)

		# 보호막 원이 화면 밖으로 나갈 만큼 크게 확대
		tween.tween_property(
			ring,
			"scale",
			Vector2.ONE * target_scale,
			shield_escape_time
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# 화면 밖으로 커지면서 서서히 사라지게 함
		tween.tween_property(
			ring,
			"modulate:a",
			0.0,
			shield_escape_time
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished

	for data in ring_data:
		var ring: Line2D = data["ring"]

		if ring:
			ring.queue_free()

	if sprite:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
#효과용 함수
func _get_ring_escape_scale(radius: float) -> float:
	var viewport_size := get_viewport_rect().size
	var center := global_position

	var corners := [
		Vector2(0, 0),
		Vector2(viewport_size.x, 0),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0, viewport_size.y)
	]

	var farthest_distance := 0.0

	for corner in corners:
		var distance := center.distance_to(corner)

		if distance > farthest_distance:
			farthest_distance = distance

	return (farthest_distance + shield_escape_margin) / radius

#효과용 함수
func _create_shield_ring(radius: float) -> Line2D:
	var ring := Line2D.new()

	ring.name = "ShieldBreakRing"
	ring.closed = true
	ring.width = shield_ring_width
	ring.default_color = Color(1.0, 0.05, 0.05, 0.9)
	ring.z_index = 20
	ring.position = Vector2.ZERO
	ring.scale = Vector2.ONE

	for i in range(shield_ring_point_count):
		var angle := TAU * float(i) / float(shield_ring_point_count)
		var point := Vector2(cos(angle), sin(angle)) * radius
		ring.add_point(point)

	return ring


# 패턴 겹치는 버그 해결용
func _cancel_current_pattern() -> void:
	pattern_run_id += 1
	is_p3_aiming = false

	if fire_timer:
		fire_timer.stop() 

func _is_pattern_cancelled(run_id: int, phase: int) -> bool:
	return (
		is_dead
		or is_phase_transitioning
		or run_id != pattern_run_id
		or current_phase != phase
	)
	
func die() -> void:
	if is_dead:
		return

	is_dead = true

	
	GlobalGameEvents.request_score_change.emit(clear_score)
	GlobalGameEvents.game_clear.emit()

	queue_free()
	
# 3페이즈 상태 기계(State Machine) 전용 함수들

# 랜덤 목적지 설정
func _set_new_p3_random_target() -> void:
	p3_target_pos = Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)

# 산책 모드: 천천히 둥둥 이동하고 잠깐 쉬기
func _process_p3_drift(delta: float) -> void:
	base_position = base_position.move_toward(p3_target_pos, p3_normal_speed * delta)
	
	if base_position.distance_to(p3_target_pos) < 5.0 and not p3_is_waiting:
		p3_is_waiting = true
		
		if current_phase == 3 and not is_dead and not is_phase_transitioning and current_p3_state == P3State.DRIFTING:
			_set_new_p3_random_target()
			p3_is_waiting = false


# 돌진 모드 대쉬 > 잠깐 멈춤 
func _process_p3_dash(delta: float) -> void:
	if p3_is_waiting:
		return
		
	base_position = base_position.move_toward(p3_target_pos, p3_dash_speed * delta)
	
	if base_position.distance_to(p3_target_pos) < 5.0:
		p3_is_waiting = true # 도착했으니 대기 
		
		# 대쉬 후 잠깐 멈춤
		await get_tree().create_timer(0.3).timeout
		
		# 탄만 쏘기
		boss_bullet_manager.fire_p3_circle_spread(base_position, variation)
		variation += 0.1
		
		# 탄막 쏘고 다시 잠깐 멈추기
		await get_tree().create_timer(0.3).timeout
		
		# 사격 후 다시 산책 모드로 복귀
		if current_phase == 3 and not is_dead and not is_phase_transitioning:
			current_p3_state = P3State.DRIFTING
			p3_is_waiting = false
			_set_new_p3_random_target()

			

# 페이즈 3 등장 애니메이션
func _play_p3_rage_and_burst() -> void:
	if not sprite: return
	
	
	# 1. 진동 효과 설정 (원래 스프라이트 중심점 기억)
	var original_offset = sprite.offset
	
	sprite.modulate = Color(2.0, 0.3, 0.3, 1.0) 
	
	# 0.5초 동안 보스를 사방으로 흔들기
	for i in range(10):
		sprite.offset = Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		await get_tree().create_timer(0.05).timeout
		
	# 진동이 끝난 후 오프셋 원상복구
	sprite.offset = original_offset
	
	# 2. 강화형 서클 탄막
	for burst in range(4):
		boss_bullet_manager.fire_p3_circle_spread(global_position, burst * 0.05)
		await get_tree().create_timer(0.05).timeout
		
	# 복구
	sprite.modulate = Color(1.0, 0.8, 0.8, 1.0)
