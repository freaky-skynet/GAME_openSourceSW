extends Node
signal player_hit_enemy(dmg)
var combo_level:int=1

signal request_score_change(amount: int)
signal score_updated(new_score: int)

signal hp_changed(current_hp: int)
signal game_over

signal boss_hp_changed(current_hp: int, max_hp: int)
signal game_clear

# 클리어 화면에서 사용할 현재 점수와 플레이어 체력
var current_score: int = 0
var current_player_hp: int = 3
