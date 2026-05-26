extends Node2D

@export var mars_texture: Texture2D
@export var jupiter_texture: Texture2D
@export var saturn_texture: Texture2D
@export var uranus_texture: Texture2D
@export var neptune_texture: Texture2D

var current_planets: Array = []
var is_transitioning: bool = false
var drift_time: float = 0.0


func _ready() -> void:
	change_phase(1, true)


func _process(delta: float) -> void:
	if is_transitioning:
		return

	drift_time += delta

	for info in current_planets:
		var planet: Sprite2D = info["sprite"]

		if not is_instance_valid(planet):
			continue

		var base_pos: Vector2 = info["base_pos"]
		var move_range: Vector2 = info["move_range"]
		var move_speed: float = info["move_speed"]
		var move_offset: float = info["move_offset"]

		var offset := Vector2(
			sin(drift_time * move_speed + move_offset) * move_range.x,
			cos(drift_time * move_speed * 0.7 + move_offset) * move_range.y
		)

		planet.position = base_pos + offset


func change_phase(phase: int, instant: bool = false) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	if not instant and current_planets.size() > 0:
		await _hide_current_planets()

	_clear_current_planets()
	_create_phase_planets(phase, instant)

	if not instant and current_planets.size() > 0:
		await _show_current_planets()

	is_transitioning = false


func _create_phase_planets(phase: int, instant: bool) -> void:
	match phase:
		1:
			_add_planet(
				mars_texture,
				Vector2(480, 130), # 위치
				Vector2(1, 1), # 크기
				instant
			)

		2:
			_add_planet(
				jupiter_texture,
				Vector2(30, 500),
				Vector2(0.6, 0.6),
				instant
			)

			_add_planet(
				saturn_texture,
				Vector2(390, 220),
				Vector2(0.24, 0.24),
				instant
			)

		3:
			_add_planet(
				uranus_texture,
				Vector2(500, -70),
				Vector2(0.6, 0.6),
				instant
			)

			_add_planet(
				neptune_texture,
				Vector2(60, 550),
				Vector2(0.1, 0.1),
				instant
			)


func _add_planet(texture: Texture2D, target_pos: Vector2, target_scale: Vector2, instant: bool) -> void:
	if texture == null:
		return

	var planet := Sprite2D.new()
	planet.texture = texture
	planet.centered = true
	planet.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

	if instant:
		planet.position = target_pos
		planet.scale = target_scale
		planet.modulate.a = 1.0
	else:
		planet.position = Vector2(target_pos.x, -180)
		planet.scale = target_scale * 0.3
		planet.modulate.a = 0.0

	add_child(planet)

	_start_planet_light_tween(planet)

	current_planets.append({
		"sprite": planet,
		"target_pos": target_pos,
		"target_scale": target_scale,
		"base_pos": target_pos,
		"move_range": Vector2(3, 2),
		"move_speed": randf_range(0.45, 0.75),
		"move_offset": randf_range(0.0, TAU)
	})


func _show_current_planets() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	for info in current_planets:
		var planet: Sprite2D = info["sprite"]
		var target_pos: Vector2 = info["target_pos"]
		var target_scale: Vector2 = info["target_scale"]

		tween.tween_property(planet, "position", target_pos, 0.8)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		tween.tween_property(planet, "scale", target_scale, 0.8)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		tween.tween_property(planet, "modulate:a", 1.0, 0.5)

	await tween.finished


func _hide_current_planets() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	for info in current_planets:
		var planet: Sprite2D = info["sprite"]

		if not is_instance_valid(planet):
			continue

		tween.tween_property(planet, "position", planet.position + Vector2(0, 350), 0.7)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

		tween.tween_property(planet, "scale", planet.scale * 2.5, 0.7)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

		tween.tween_property(planet, "modulate:a", 0.0, 0.7)

	await tween.finished


func _clear_current_planets() -> void:
	for info in current_planets:
		var planet: Sprite2D = info["sprite"]

		if is_instance_valid(planet):
			planet.queue_free()

	current_planets.clear()


func _start_planet_light_tween(planet: Sprite2D) -> void:
	var tween := planet.create_tween()
	tween.set_loops()

	tween.tween_property(planet, "self_modulate", Color(0.55, 0.55, 0.55, 1.0), 1.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(planet, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 1.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
