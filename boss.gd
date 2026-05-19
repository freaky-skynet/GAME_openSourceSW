extends CharacterBody2D

@export var max_hp: int = 1000
@export var hit_flash_time: float = 0.08
@export var clear_score: int = 3000

@onready var boss_bullet_manager = %BossBulletManager
@onready var pattern1_timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_hp: int = 100
var pos: Vector2 = Vector2.ZERO
var variation: float = 0.0
var is_dead: bool = false


func _on_ready() -> void:
	current_hp = max_hp
	pos = global_position

	GlobalGameEvents.boss_hp_changed.emit(current_hp, max_hp)

	if pattern1_timer:
		pattern1_timer.start()


func _on_timer_timeout() -> void:
	pattern1_shoot()


func pattern1_shoot() -> void:
	if is_dead:
		return

	if variation > 20.0:
		variation = 0.0

	boss_bullet_manager.fire_pattern1_radial(pos, variation)
	variation += 3.0


func take_damage(amount: int) -> void:
	if is_dead:
		return

	if amount <= 0:
		return

	current_hp -= amount
	current_hp = max(current_hp, 0)

	print("보스 현재 체력: ", current_hp, "/", max_hp)

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


func die() -> void:
	if is_dead:
		return

	is_dead = true

	if pattern1_timer:
		pattern1_timer.stop()

	GlobalGameEvents.request_score_change.emit(clear_score)
	GlobalGameEvents.game_clear.emit()

	queue_free()
