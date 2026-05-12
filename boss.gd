extends CharacterBody2D

@onready var boss_bullet_manager=%BossBulletManager
@onready var pattern1_timer = $Timer
var pos=Vector2.ZERO
var variation=0.0

func _on_ready() -> void:
	pattern1_timer.start()
	pos =global_position

func _on_timer_timeout() -> void:
	pattern1_shoot()

func pattern1_shoot():
	if(variation>20) : variation=0.0
	boss_bullet_manager.fire_pattern1_radial(pos,variation)
	variation+=3
