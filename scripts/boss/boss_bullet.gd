extends Area2D

@export var speed: float = 500.0
var default_speed: float = 500.0

@export var boss_scene: PackedScene
var direction: Vector2 = Vector2.ZERO
var is_active: bool = false

@export var anim_fps: float = 15.0     # 초당 프레임 속도
var current_frame: float = 0.0
@onready var sprite = $Sprite2D

func _ready():
	default_speed = speed
	# 처음에 생성될 때는 비활성화 상태로 시작
	deactivate()

func _physics_process(delta):
	if not is_active:
		return
	
	# 탄환 이동 로직
	position += direction * speed * delta
	
	# 총알 사진 로직
	current_frame += delta * anim_fps
	if current_frame >= 22.0:
		current_frame = 0.0
	sprite.frame = int(current_frame)
	
	# 화면 밖으로 나가면 스스로 비활성화 (화면 크기는 프로젝트 설정을 따름)
	var screen_size = get_viewport_rect().size
	if position.x < -20 or position.x > screen_size.x + 20 or \
	   position.y < -20 or position.y > screen_size.y + 20:
		deactivate()

func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("take_damage"):
		body.take_damage(1)
	deactivate()


# 탄환을 다시 사용할 때 호출
func activate(pos: Vector2, dir: Vector2, new_speed: float = -1.0):
	position = pos
	direction = dir.normalized()
	
	if new_speed > 0.0: speed = new_speed
	else: speed = default_speed
	
	is_active = true
	show()
	# 물리 충돌과 프로세스를 다시 
	set_process(true)
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

# 탄환 비활성화 함수
func deactivate():
	is_active = false
	speed = default_speed
	hide()
	# 성능 최적화(연산 제거)
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
