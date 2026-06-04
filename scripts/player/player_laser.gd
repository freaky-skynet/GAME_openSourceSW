extends RayCast2D

@export var damage: int = 5
@export var damage_interval: float = 0.2

@onready var player = $"../ObjectLayer/Player"
@onready var line: Line2D = $Line2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_damage: bool = true


func _ready() -> void:
	deactivate()


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


func _try_damage(target: Object) -> void:
	if not can_damage:
		return

	can_damage = false

	target.take_damage(damage)
	GlobalGameEvents.player_hit_enemy.emit(damage)
	
	GlobalGameEvents.request_score_change.emit(100)#버그 수정 레이저도 점수 추가
	
	await get_tree().create_timer(damage_interval).timeout

	can_damage = true


func emit_hit_signal() -> void:
	GlobalGameEvents.player_hit_enemy.emit(damage)


func activate() -> void:
	show()
	enabled = true
	set_process(true)


func deactivate() -> void:
	hide()
	enabled = false
	set_process(false)
	can_damage = true
