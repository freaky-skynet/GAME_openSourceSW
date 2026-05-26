extends Node2D

@export var mars_texture: Texture2D
@export var jupiter_texture: Texture2D
@export var saturn_texture: Texture2D
@export var uranus_texture: Texture2D
@export var neptune_texture: Texture2D

var current_planets: Array = []
var is_transitioning := false


func _ready() -> void:
	change_phase(1, true)


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
				Vector2(350, 130),
				Vector2(0.35, 0.35),
				instant
			)

		2:
			_add_planet(
				jupiter_texture,
				Vector2(330, 120),
				Vector2(0.32, 0.32),
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
				Vector2(320, 130),
				Vector2(0.28, 0.28),
				instant
			)

			_add_planet(
				neptune_texture,
				Vector2(390, 250),
				Vector2(0.25, 0.25),
				instant
			)


func _add_planet(texture: Texture2D, target_pos: Vector2, target_scale: Vector2, instant: bool) -> void:
	if texture == null:
		return

	var planet := Sprite2D.new()
	planet.texture = texture
	planet.centered = true

	if instant:
		planet.position = target_pos
		planet.scale = target_scale
		planet.modulate.a = 1.0
	else:
		planet.position = Vector2(target_pos.x, -180)
		planet.scale = target_scale * 0.3
		planet.modulate.a = 0.0

	add_child(planet)

	current_planets.append({
		"sprite": planet,
		"target_pos": target_pos,
		"target_scale": target_scale
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
