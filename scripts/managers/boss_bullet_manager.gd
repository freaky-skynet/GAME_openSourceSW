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
			bullet.activate(pos,dir)

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
