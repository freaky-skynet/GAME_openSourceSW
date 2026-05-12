extends Node2D

@export var player_bullet: PackedScene # 에디터에서 Bullet.tscn을 연결
@export var pool_size: int = 200 # 미리 만들어둘 탄환 개수
var bullet_pool: Array = []

func _ready():
	# 게임이 시작될 때 탄환 오브젝트 풀링 
	if player_bullet:
		for i in range(pool_size):
			var bullet = player_bullet.instantiate()
			add_child(bullet)
			bullet_pool.append(bullet)
	else:
		push_error("NO SCENE ATTACHED")

# 탄환 발사 호출
func fire_bullet(pos: Vector2, dir: Vector2):
	var bullet = _get_inactive_bullet()
	if bullet:
		bullet.activate(pos, dir)
	else:
		# 탄환이 모자라면
		print("Bullet pool is full")

# object "pull"ing from pool
func _get_inactive_bullet():
	for bullet in bullet_pool:
		if not bullet.is_active:
			return bullet
	return null
