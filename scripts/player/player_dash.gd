extends Node

@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 3.0
@export var dash_invincible_duration: float = 1.0 # 무적 시간

# 자식 노드 변수값 갖고오기
@onready var player: CharacterBody2D = get_parent()
@onready var dash_duration_timer: Timer = $"../DashDurationTimer"
@onready var dash_cooldown_timer: Timer = $"../DashCooldownTimer"
@onready var dash_invincible_timer: Timer = $"../DashInvincibleTimer"

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var last_move_direction: Vector2 = Vector2.UP
# 가만히 있을 때 dash 누르면 이 방향으로 나감

# timer 연결
func _ready():
	dash_duration_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_invincible_timer.wait_time = dash_invincible_duration
	
	dash_duration_timer.timeout.connect(_on_dash_duration_timer_timeout)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)
	dash_invincible_timer.timeout.connect(_on_dash_invincible_timer_timeout)
	
	
# direaction 가져옴
func update_last_direction(input_direction: Vector2):
	if input_direction != Vector2.ZERO:
		last_move_direction = input_direction.normalized()

# dash 눌렀을 때 -> player.gd에서 호출
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

func get_dash_velocity() -> Vector2:
	return dash_direction * dash_speed

func _on_dash_duration_timer_timeout():
	is_dashing = false

func _on_dash_cooldown_timer_timeout():
	can_dash = true
	
func _on_dash_invincible_timer_timeout():
	player.barrier_sprite.hide()
	player.barrier_sprite.pause()
	player.is_invincible = false
