extends Node2D


func _ready():
	var bg = Sprite2D.new()
	bg.texture = load("res://assets Nikita/backgrounds/bg_menu.png")
	bg.position = Vector2(640, 360)
	bg.scale = Vector2(1280.0 / bg.texture.get_width(), 720.0 / bg.texture.get_height())
	add_child(bg)

	var label = Label.new()
	label.text = "Подготовка к уровню"
	label.position = Vector2(400, 200)
	label.scale = Vector2(2, 2)
	add_child(label)

	var level_id = GameManager.last_result.get("next_level", "level_01")
	GameManager.last_result["next_level"] = level_id

	var num_label = Label.new()
	num_label.text = "Уровень: " + level_id
	num_label.position = Vector2(400, 280)
	add_child(num_label)

	var level_config = _load_level(level_id)
	if level_config:
		var info = Label.new()
		info.text = "Время: %d сек | Монеты: %d | Кристаллы: %d" % [level_config.time_limit, level_config.starting_coins, level_config.crystal_reward]
		info.position = Vector2(400, 340)
		add_child(info)

		var egg_counts = {}
		for w in level_config.waves:
			var cfg = w.egg_config
			if cfg:
				egg_counts[cfg.display_name] = egg_counts.get(cfg.display_name, 0) + 1
		var y = 400
		for eid in egg_counts:
			var el = Label.new()
			el.text = "%s x%d" % [eid, egg_counts[eid]]
			el.position = Vector2(400, y)
			add_child(el)
			y += 30

	var play_tex = load("res://assets Nikita/buttons/button_play.png") as Texture2D
	if play_tex:
		var btn = TextureButton.new()
		btn.texture_normal = play_tex
		btn.position = Vector2(640 - play_tex.get_width() * 0.5, 560)
		btn.pressed.connect(_on_play_pressed)
		add_child(btn)


func _load_level(level_id: String) -> LevelConfig:
	var path = "res://assets/configs/%s.tres" % level_id
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _on_play_pressed():
	GameManager.go_to_scene("res://scenes/game.tscn")
