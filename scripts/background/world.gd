extends Node2D

@onready var planet_layer: Node2D = $PlanetLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_connect_boss_phase_signal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _connect_boss_phase_signal() -> void:
	var boss = get_tree().get_first_node_in_group("boss")
	if boss == null: return
	boss.phase_changed.connect(_on_boss_phase_changed)

func _on_boss_phase_changed(new_phase: int) -> void:
	planet_layer.change_phase(new_phase)
