### 오픈소스SW개론 12조
# 최종프로젝트 : 탄막슈팅게임

<img width="665" height="643" alt="스크린샷 2026-06-07 232749" src="https://github.com/user-attachments/assets/29a17539-f19e-4d6e-ad72-bd4d18ca0b95" />
---


**목차**

- [개요 및 실행방법](#개요-및-실행방법)
- [기능과 구현](#기능과-구현)
- [프로그램 사용법](#프로그램-사용법)
- [라이선스](#라이선스)


## 개요 및 실행방법
12조는 탄막슈팅게임을 주제로 오픈소스SW개론 최종프로젝트를 진행하였습니다. 이 게임은 GPL 3.0 라이선스를 통해 배포되는 오픈소스 소프트웨어이며,
오픈소스 게임엔진인 Godot v4.6.2 버전을 사용하여 개발되었습니다.
Release 탭의 [V1.0.0](https://github.com/freaky-skynet/GAME_openSourceSW/releases/tag/V1.0.0)에서 게임엔진이 필요없는 실행 파일을 직접 다운로드 받으실 수 있습니다.

원격저장소를 클론하여 게임을 실행하시는 경우에는, 다음 사이트에서 Godot v4.6.2 버전을 다운로드 받으신 후 다음 지침을 따라주세요.
> [Godot Engine 다운로드 사이트](https://godotengine.org/download/archive/).



<img width="600" height="350" alt="스크린샷 2026-06-07 233650" src="https://github.com/user-attachments/assets/bc819ff8-7c01-49da-b324-85585fb3cde5" />

파일을 다운받으셨다면 압축을 해제하고, 뒤에 console이 붙지 않은 실행파일을 여시면 됩니다.
<img width="648" height="101" alt="image" src="https://github.com/user-attachments/assets/42a6957c-146d-42ec-96ce-8503b28fa349" />


이후 상단에서 프로젝트 가져오기를 누르신 후에,
<img width="1143" height="108" alt="image" src="https://github.com/user-attachments/assets/6e543af1-2d57-46b2-8181-ae3c34f73aa0" />

클론한 저장소 속 project.godot 을 열어주세요.

<img width="400" height="300" alt="스크린샷 2026-06-07 233930" src="https://github.com/user-attachments/assets/f495521b-b50a-4297-91f9-0fa66f9de2fd" />

Godot의 첫 화면입니다. 여기서 우측 상단에 보시면 재생 버튼이 보이실 겁니다.
<img width="600" height="300" alt="스크린샷 2026-06-07 234032" src="https://github.com/user-attachments/assets/5b66df98-787e-433d-988e-043e80adaf29" />

재생 버튼을 누르면 곧바로 게임이 실행됩니다.
<img width="260" height="39" alt="스크린샷 2026-06-07 234028" src="https://github.com/user-attachments/assets/f6b9d65f-9fe3-4c76-9871-708c1fd0d0c8" />

화면 하단에서는 터미널을 통해 현재 게임의 진행 상황을 실시간으로 확인할 수 있으며, 
<img width="700" height="500" alt="스크린샷 2026-06-07 234145" src="https://github.com/user-attachments/assets/2e4fe99e-5c01-492b-8136-17f7dd1db40e" />
<img width="197" height="408" alt="image" src="https://github.com/user-attachments/assets/3f31f216-59d4-453f-890c-9e1b7712db47" />



좌측 씬 트리의 '원격' 부분을 누르시면 현재 각 노드가 가진 멤버변수들의 변화 등을 실시간으로 확인 가능합니다.


***





## 기능과 구현
다음으로 코드는 일부만 발췌하여 어떤 기능을 수행하는지 설명하겠습니다.


```
#planet_layer.gd(일부)

func _start_planet_light_tween(planet: Sprite2D) -> void:
	var tween := planet.create_tween()
	tween.set_loops()

	tween.tween_property(planet, "self_modulate", Color(0.55, 0.55, 0.55, 1.0), 1.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(planet, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 1.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

```
tween 객체를 통해 배경의 행성을 움직이고, 페이즈에 따라 변화시키는 스크립트입니다.

```
#world.gd
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

```
메인 씬인 World.tscn에 부착되어 게임 시작을 담당하는 코드입니다. await 문을 통해 일시정지 후 게임이 시작되도록 합니다.


```
#boss_bullet.gd
func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("take_damage"):
		body.take_damage(1)
	deactivate()
```
보스 총알 스크립트입니다. 플레이어에 닿으면 플레이어의 take_damage 메소드를 실행시켜 데미지를 입히고, deactive()를 통해 사라집니다.


```
#boss.gd
func phase_manager(current_hp:int,_max_hp:int)->void:
	#현재 체력에 따라 페이즈를 바꿈 
	#print(phase_point1," ",phase_point2," ",current_hp)
	var before_phase: int = current_phase
	
	if (phase_point2 <= current_hp && current_hp <= phase_point1):
		current_phase=2
		#print("PHASE2")
	elif (current_hp < phase_point2):
		current_phase=3
		#print("PHASE3")
		
	if before_phase != current_phase:
		#print("PHASE", current_phase)
		
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
```
가장 기능이 많은 보스의 코드입니다. 체력에 따라 페이즈가 바뀌어 공격 패턴이 변경됩니다. boss_attack() 메소드를 통해서 공격을 실행하며, 이 때에도 보스 자신의 current_phase를 참조하여 어떤 공격을 수행할지 결정합니다.

```
#boss_bullet_manager.gd
func fire_p3_aimed(pos: Vector2, target_pos: Vector2):
	var bullet_count = 3
	var spread_angle = deg_to_rad(12) # 총알 사이의 벌어지는 각도 (12도)
	var base_angle = (target_pos - pos).angle()
	
	for i in range(bullet_count):
		var bullet = _get_inactive_bullet()
		if bullet:
			var angle = base_angle + (i - 1) * spread_angle
			var dir = Vector2.from_angle(angle)
			bullet.activate(pos, dir, 350.0)
```
위와 비슷한 공격패턴 코드를 여러 개 가진 boss_bullet_manager 노드에 붙은 코드입니다. 각도를 설정하고 target_pos를 플레이어 위치로 삼아 총알을 발사합니다.

```
#combo_manager.gd
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
```
콤보 매니저 노드에 붙어 보스가 플레이어 총알에 맞으면 콤보 카운터가 올라가도록 하는 코드입니다. GlobalGameEvents의 combo_level을 변경하여 여러 노드에서 쉽게 참조할 수 있도록 하였습니다.


```
#player_bullet_manager.gd
func fire_bullet(pos: Vector2, dir: Vector2):
	if GlobalGameEvents.combo_level<3:
		var bullet = _get_inactive_bullet()
		if bullet:
			bullet.activate(pos, dir)
		else:
			# 탄환이 모자라면
			print("Bullet pool is full")
	else:
		player_laser.activate()
```
플레이어 총알을 관리하는 노드의 스크립트입니다. 콤보 레벨에 따라 공격 키를 눌렀을 때 나가는 총알의 탄종을 달리합니다.

레벨 3의 경우에는 player_laser.activate() 코드가 작동하는 것을 볼 수 있습니다.


```
#player_dash.gd
func try_dash(input_direction: Vector2):
	if not can_dash:
		return
	
	can_dash = false
	is_dashing = true
	player.is_invincible = true # 무적 발동
	
	if input_direction != Vector2.ZERO:
		dash_direction = input_direction.normalized()
	else:
		dash_direction = last_move_direction
	
	print("dash!!!")
	
	dash_duration_timer.start()
	dash_cooldown_timer.start()
	dash_invincible_timer.start()
	player.barrier_sprite.show()
	player.barrier_sprite.play("default")
```
플레이어가 대쉬 기능을 활성화하면 현재 대쉬를 사용 가능한지 체크하여 대쉬를 수행하는 코드입니다.


```
#player_laser.gd
func _process(_delta: float) -> void:
	if not player:
		return
	global_position = player.global_position
	line.set_point_position(1, target_position)
	
	if GlobalGameEvents.combo_level<3:
		hide()
		enabled=false

	if is_colliding():
		line.set_point_position(1, to_local(get_collision_point()))

		var target := get_collider()

		if target and target.has_method("take_damage"):
			_try_damage(target)
```
플레이어 레이저는 raycast 2D 노드를 통해 구현되었으며, 끝점이 보스와 만나면 거기까지만 Line2D 오브젝트를 
그려 레이저를 구현하였습니다.

```
#player.gd
func take_damage(amount: int):
	# 무적 체크박스가 켜져 있다면, 아래 코드를 무시하고 함수를 나감.
	if is_invincible:
		return 

	current_hp -= amount
	current_hp = max(0, current_hp)
	
	GlobalGameEvents.current_player_hp = current_hp
	
	print("현재 피: ", current_hp)
	GlobalGameEvents.hp_changed.emit(current_hp)
	#피격 스프라이트 및 효과음 출력
	explosion_sprite.show()
	explosion_sprite.play("default")
	damaged_sfx.play()
	
	if current_hp <= 0:
		die()
		return
	#죽지 않았다면 무적시간 부여(await문 참조)
	is_invincible=true
	print("플레이어 무적 부여")
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate:a", 0.5, 0.3) # 반투명하게
	tween.tween_property(player_sprite, "modulate:a", 1.0, 0.3) # 다시 보이게
	await get_tree().create_timer(1.0).timeout
	explosion_sprite.hide()
	print("무적 종료")
	is_invincible=false
```
플레이어가 보스 총알에 맞을 때 수행되는 코드입니다. 현재 체력이 0보다 크다면 총알에 맞았을 때 플레이어에게 무적시간을 부여합니다.
이때 플레이어는 데미지를 입지 않습니다.


---


## 프로그램 사용법

<img width="507" height="480" alt="image" src="https://github.com/user-attachments/assets/545810ce-5ab1-4420-b96b-015c3c609571" />

Godot을 다운로드 받으셨다면 Godot 프로그램 내에서 여러가지 export된 변수들을 통해 게임의 난이도 등을 조절할 수 있습니다.
대표적으로 boss 씬을 좌흑 하단의 파일시스템에서 열면, 우측의 인스펙터 창에서 변수값을 직접 조정할 수 있습니다. 이 값들은
스크립트 내에서 쓰이는 값이지만 export로 내보내져 인스펙터 창에서 조절하면 스크립트에도 자동으로 반영됩니다.

<img width="352" height="195" alt="image" src="https://github.com/user-attachments/assets/54b063d9-e16f-48c2-86ba-66f4881bbfb5" />


예를 들어 Max Hp 값을 100으로 조정하면, 기존 보스의 최대체력이 1000이었기 때문에 게임을 상당히 쉬운 난이도로 클리어할 수 있습니다.
또한 Fire Time을 0.1초보다 더 길게 만들면, 패턴 발사 속도를 늦추어 회피가 용이해지도록 할 수 있습니다.

---

## 라이선스

이 게임은 GPL 3.0 라이선스를 통해 배포되는 오픈소스 소프트웨어입니다.
라이선스 파일이 원격저장소에 포함됩니다.
