extends Node2D

@onready var player=$/root/World/ObjectLayer/Player
@export var boss_bullet: PackedScene # 에디터에서 연결
@export var pool_size: int = 500 # 미리 만들어둘 탄환 개수
@export var fire_unit: int = 32
var bullet_pool: Array = []

func _ready():
	# 게임이 시작될 때 탄환 오브젝트 풀링 
	if boss_bullet:
		for i in range(pool_size):
			var bullet = boss_bullet.instantiate()
			add_child(bullet)
			bullet_pool.append(bullet)
	else:
		push_error("NO SCENE ATTACHED")

func fire_p1_pattern1_radial(pos:Vector2,adjust:float):
	# TAU는 360도를 라디안으로 나타낸 값
	# 한 발당 간격 구하기 
	var angle_step = TAU / fire_unit
	for i in range(fire_unit):
		#풀에서 비활성화된 총알 호출
		var bullet = _get_inactive_bullet()
		
		if bullet:
			#방향 계산 (i번째 각도 구하기)
			var current_angle
			current_angle = i * angle_step+adjust
			# from_angle은 해당 각도로 크기가 1인 방향 벡터를 만듦
			var dir = Vector2.from_angle(current_angle)
			#활성화 함수 호출
			bullet.activate(pos,dir,500.0)

# 촘촘
# 보스를 중심으로 원형으로 총알을 18발 쏨 (4초동안 18발), 회전O
func fire_p2_rotating_radial(pos: Vector2, adjust: float):
	var bullet_count = 18
	var bullet_angle = 6
	var angle_step = TAU / bullet_angle

	for i in range(bullet_count):
		var bullet = _get_inactive_bullet()

		if bullet:
			var angle = i * angle_step + adjust
			var dir = Vector2.from_angle(angle)
			bullet.activate(pos, dir, 300.0) #촘촘하나 느리다....


# 플레이어 찾아서 부채꼴 모양으로 탄환 발사
func fire_p2_aimed_spread(pos: Vector2, target_pos: Vector2):
	var bullet_count = 6
	var spread_angle = deg_to_rad(10)
	var base_angle = (target_pos - pos).angle()

	for i in range(bullet_count):
		var bullet = _get_inactive_bullet()

		if bullet:
			var t = 0.0
			if bullet_count > 1:
				t = float(i) / float(bullet_count - 1)
			
			var angle = base_angle - spread_angle / 2.0 + spread_angle * t
			var dir = Vector2.from_angle(angle)
			bullet.activate(pos, dir, 450.0)

# 십자 회전 탄막 (상하좌우 3발씩)
func fire_p2_cross_spread(pos: Vector2, adjust: float):
	var spread = deg_to_rad(3)
	
	for i in range(4):
		var base_angle = i * PI / 2.0 + adjust
		for j in range(-1, 2):
			var bullet = _get_inactive_bullet()
			if bullet:
				var angle = base_angle + spread * j
				var dir = Vector2.from_angle(angle)
				bullet.activate(pos, dir, 450.0)

func fire_p3_circle_spread(pos: Vector2, adjust: float):
	var bullet_count = 36 
	var angle_step = TAU / bullet_count
	
	for i in range(bullet_count):
		var bullet = _get_inactive_bullet()
		if bullet:
			var angle = i * angle_step + adjust
			var dir = Vector2.from_angle(angle)
			
			# 탄알 속도 450
			bullet.activate(pos, dir, 450.0)

func fire_p3_aimed_single(pos: Vector2, target_pos: Vector2):
	var bullet = _get_inactive_bullet() # 총알 한 개만 꺼내기
	
	if bullet:
		# 그냥 플레이어를 향한 직행 각도
		var angle = (target_pos - pos).angle() 
		var dir = Vector2.from_angle(angle)
		# 탄알 속도
		bullet.activate(pos, dir, 500.0)

func fire_p1_pattern2_follow(pos:Vector2):
	#처음 발사 후 정지, 이후 현재 플레이어 위치를 dir로 하여 다시 이동
	var angle_step= TAU / 12
	for i in range(fire_unit):
		var bullet = _get_inactive_bullet()
		
		if bullet:
			var current_angle
			current_angle=i*angle_step
			var dir = Vector2.from_angle(current_angle)
			bullet.activate(pos,dir)
			await get_tree().create_timer(0.25).timeout
			if bullet:#충돌 안났어야함(충돌나면 없어지니까)
				bullet.deactivate()
				bullet.show()
				dir=bullet.global_position.direction_to(player.global_position)
				bullet.activate(bullet.global_position,dir)
				
func fire_p1_pattern3_shunrai():#플레이어 위치로 일렬발사
	if player == null:
		player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
	var player_x = player.global_position.x
	for i in range(fire_unit):
		var bullet = _get_inactive_bullet()
		
		if bullet:
			var dir = Vector2(0,1)
			bullet.global_position.x=player_x
			bullet.global_position.y=0
			bullet.activate(bullet.global_position,dir)
			await get_tree().create_timer(0.05).timeout

# object "pull"ing from pool
func _get_inactive_bullet():
	for bullet in bullet_pool:
		if not bullet.is_active:
			return bullet
	return null
