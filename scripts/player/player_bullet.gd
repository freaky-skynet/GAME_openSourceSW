extends Area2D

@export var speed: float = 500.0

var twin_bullet_texture: Texture2D
var normal_bullet_texture: Texture2D
var sprite: Sprite2D

var direction: Vector2 = Vector2.ZERO
var is_active: bool = false


func _ready() -> void:
	sprite = $Sprite2D

	normal_bullet_texture = load("res://assets/images/bullets/playerbullet.png")
	twin_bullet_texture = load("res://assets/images/bullets/playerBulleL2.png")

	# 보스 collision_layer가 16이므로 플레이어 탄환이 16번 레이어를 감지해야 함
	collision_mask = collision_mask | 16

	var body_entered_callable := Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_entered_callable):
		body_entered.connect(body_entered_callable)

	deactivate()


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	position += direction * speed * delta

	if _is_outside_screen():
		deactivate()


func _on_body_entered(body: Node) -> void:
	if not is_active:
		return

	var damage := _get_damage_by_combo_level()

	if body.has_method("take_damage"):
		body.take_damage(damage)
		GlobalGameEvents.player_hit_enemy.emit(damage)

		if GlobalGameEvents.combo_level >= 2:
			GlobalGameEvents.request_score_change.emit(500)

	deactivate()


func activate(pos: Vector2, dir: Vector2) -> void:
	match GlobalGameEvents.combo_level:
		1:
			sprite.texture = normal_bullet_texture
		2:
			sprite.texture = twin_bullet_texture
		_:
			sprite.texture = twin_bullet_texture

	bullet_activate(pos, dir)


func bullet_activate(pos: Vector2, dir: Vector2) -> void:
	position = pos
	direction = dir.normalized()
	is_active = true

	show()

	set_process(true)
	set_physics_process(true)

	set_deferred("monitoring", true)
	set_deferred("monitorable", true)


func deactivate() -> void:
	is_active = false

	hide()

	set_process(false)
	set_physics_process(false)

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)


func _get_damage_by_combo_level() -> int:
	match GlobalGameEvents.combo_level:
		1:
			return 1
		2:
			return 5
		_:
			return 5


func _is_outside_screen() -> bool:
	var screen_size := get_viewport_rect().size

	return (
		position.x < -20.0
		or position.x > screen_size.x + 20.0
		or position.y < -20.0
		or position.y > screen_size.y + 20.0
	)
