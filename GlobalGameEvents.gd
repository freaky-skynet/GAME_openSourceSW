extends Node
signal player_hit_enemy(dmg)
var combo_level:int=1

signal request_score_change(amount)
signal score_updated(new_score)

# GlobalGameEvents.gd
signal hp_changed(current_hp)

# GlobalGameEvents.gd
signal game_over
