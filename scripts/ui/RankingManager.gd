extends Node

const SAVE_PATH := "user://ranking.json"
const MAX_RANKING_COUNT := 5

var rankings: Array = []


func _ready() -> void:
	load_rankings()


func add_record(score: int, clear_time: float, finished_at: String, result_type: String) -> Array:
	var record := {
		"score": score,
		"clear_time": clear_time,
		"finished_at": finished_at,
		"result_type": result_type
	}

	rankings.append(record)
	rankings.sort_custom(_sort_ranking)

	while rankings.size() > MAX_RANKING_COUNT:
		rankings.pop_back()

	save_rankings()

	return rankings


func _sort_ranking(a: Dictionary, b: Dictionary) -> bool:
	if a["score"] != b["score"]:
		return a["score"] > b["score"]

	return a["clear_time"] < b["clear_time"]


func save_rankings() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("Ranking save failed")
		return

	file.store_string(JSON.stringify(rankings, "\t"))
	file.close()


func load_rankings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		rankings = []
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("Ranking load failed")
		rankings = []
		return

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) == TYPE_ARRAY:
		rankings = parsed
	else:
		rankings = []


func get_ranking_text() -> String:
	if rankings.is_empty():
		return "랭킹 기록 없음"

	var text := "[ 랭킹 TOP 5 ]\n"

	for i in range(rankings.size()):
		var record: Dictionary = rankings[i]

		text += "%d위  %d점  %s  %s\n" % [
			i + 1,
			int(record["score"]),
			format_time(float(record["clear_time"])),
			str(record["result_type"])
		]

	return text


func format_time(time_sec: float) -> String:
	var total_sec := int(time_sec)
	var minutes := int(total_sec / 60)
	var seconds := total_sec % 60
	var milliseconds := int((time_sec - total_sec) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
