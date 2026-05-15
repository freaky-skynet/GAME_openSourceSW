extends RayCast2D
@onready var player=$"../ObjectLayer/Player"
@onready var line = $Line2D
var offset:Vector2=Vector2(0,-30)

func _ready():
	deactivate()
	
func _process(delta):
	global_position=player.global_position
	line.set_point_position(0, target_position) # 기본은 최대 사거리
	if is_colliding():
		print("COLLIDE!")
		line.set_point_position(0, to_local(get_collision_point()))
		GlobalGameEvents.player_hit_enemy.emit(5)

func activate():
	show()
	enabled=true
	set_process(true)

func deactivate():
	hide()
	enabled=false
	set_process(false)
