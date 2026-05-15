extends Area2D

@export var speed: float = 500.0
var twinBullet_texture: Texture2D
var normalBullet_texture:Texture2D
var sprite:Sprite2D

var direction: Vector2 = Vector2.ZERO
var is_active: bool = false
var dmg = 0#콤보레벨과 연계, on_body_entered에서 레벨에 따른 데미지 차등부여

func _ready():
	sprite=$Sprite2D
	normalBullet_texture = load("res://playerbullet.png")
	twinBullet_texture = load("res://playerBulleL2.png")
	deactivate()

func _physics_process(delta):
	if not is_active:
		return
	
	# 탄환 이동 로직
	position += direction * speed * delta
	
	# 화면 밖으로 나가면 스스로 비활성화 (화면 크기는 프로젝트 설정을 따름)
	var screen_size = get_viewport_rect().size
	if position.x < -20 or position.x > screen_size.x + 20 or \
		position.y < -20 or position.y > screen_size.y + 20:
		deactivate()
		
func _on_body_entered(_body):
	match GlobalGameEvents.combo_level:
		1:
			GlobalGameEvents.player_hit_enemy.emit(1)#damage 1
		2:#combo_level= 2
			GlobalGameEvents.player_hit_enemy.emit(5)#damage 5
	deactivate()

# 탄환을 다시 사용할 때 호출
func activate(pos: Vector2, dir: Vector2):
	match GlobalGameEvents.combo_level:
		1:
			sprite.texture=normalBullet_texture
			bullet_activate(pos,dir)
		2:#level 2, twin bullets
			sprite.texture=twinBullet_texture
			bullet_activate(pos,dir)

#탄환전용 활성화함수 
func bullet_activate(pos: Vector2, dir: Vector2):
	position = pos
	direction = dir.normalized()
	is_active = true
	show()
	# 물리 충돌과 프로세스를 다시 켬 
	set_process(true)
	set_physics_process(true)
	monitoring = true
	monitorable = true
	
# 탄환 비활성화 함수
func deactivate():
	is_active = false
	hide()
	# 성능 최적화(연산 제거)
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
