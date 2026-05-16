extends Parallax2D


@export var scroll_speed: Vector2 = Vector2(0, 100)

func _process(delta):
	scroll_offset += scroll_speed * delta
