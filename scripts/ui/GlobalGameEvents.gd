extends Node
signal player_hit_enemy(dmg)
var combo_level:int=1

signal request_score_change(amount: int)
signal score_updated(new_score: int)

signal hp_changed(current_hp: int)
signal game_over

signal boss_hp_changed(current_hp: int, max_hp: int)
signal game_clear
