extends Node2D

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

func fire_pattern1_radial(pos:Vector2,adjust:float):
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


# object "pull"ing from pool
func _get_inactive_bullet():
	for bullet in bullet_pool:
		if not bullet.is_active:
			return bullet
	return null
