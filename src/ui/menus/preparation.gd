extends Node2D

var level_config: LevelConfig
var _level_id: String = "level_01"

const LEVEL_PATHS: Dictionary = {
	"level_01": "res://assets/configs/level_01.tres",
	"level_02": "res://assets/configs/level_02.tres",
	"level_03": "res://assets/configs/level_03.tres"
}


func _ready():
	_add_background("res://assets Nikita/backgrounds/bg_menu.png")

	_level_id = GameManager.last_result.get("next_level", "level_01")
	var path = LEVEL_PATHS.get(_level_id)
	if path and ResourceLoader.exists(path):
		level_config = load(path)
	if not level_config:
		level_config = load("res://assets/configs/level_01.tres")

	GameManager.last_result["next_level"] = _level_id

	var level_num = 1
	if _level_id.begins_with("level_"):
		level_num = _level_id.trim_prefix("level_").to_int()

	var title = Label.new()
	title.text = "Уровень %d: %s" % [level_num, level_config.display_name if level_config else "???"]
	title.position = Vector2(480, 180)
	title.scale = Vector2(2, 2)
	add_child(title)

	if level_config:
		var info = Label.new()
		info.text = "Время: %d сек\nСтартовые монеты: %d\nНаграда: %d кристаллов" % [
			level_config.time_limit, level_config.starting_coins, level_config.crystal_reward
		]
		info.position = Vector2(480, 280)
		add_child(info)

		var egg_counts = {}
		for w in level_config.waves:
			if w and w.egg_config:
				var eid = w.egg_config.display_name
				egg_counts[eid] = egg_counts.get(eid, 0) + 1

		if not egg_counts.is_empty():
			var header = Label.new()
			header.text = "Яйца:"
			header.position = Vector2(480, 400)
			add_child(header)

			var idx = 0
			for eid in egg_counts:
				var el = Label.new()
				el.text = "  %s x%d" % [eid, egg_counts[eid]]
				el.position = Vector2(480, 430 + idx * 25)
				add_child(el)
				idx += 1

	_add_button("res://assets Nikita/buttons/button_play.png", Vector2(640, 560), _on_play_pressed)


func _add_background(path: String):
	if ResourceLoader.exists(path):
		var bg = Sprite2D.new()
		bg.texture = load(path)
		bg.position = Vector2(640, 360)
		var tex = load(path) as Texture2D
		if tex:
			bg.scale = Vector2(1280.0 / tex.get_width(), 720.0 / tex.get_height())
		add_child(bg)


func _add_button(path: String, pos: Vector2, callback: Callable):
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex:
			var btn = TextureButton.new()
			btn.texture_normal = tex
			btn.position = pos - tex.get_size() * 0.5
			btn.pressed.connect(callback)
			add_child(btn)


func _on_play_pressed():
	AudioManager.play_sfx("res://assets/audio/click.wav")
	GameManager.go_to_scene("res://scenes/game.tscn")
