extends Node2D

const LEVEL_IDS: Array = ["level_01", "level_02", "level_03"]
const LEVEL_PATHS: Dictionary = {
	"level_01": "res://assets/configs/level_01.tres",
	"level_02": "res://assets/configs/level_02.tres",
	"level_03": "res://assets/configs/level_03.tres"
}


func _ready():
	_add_background("res://assets Nikita/backgrounds/bg_levels.png")
	_add_button("res://assets Nikita/buttons/button_back.png", Vector2(80, 650), _on_back_pressed)
	_draw_levels()


func _draw_levels():
	var unlocked = SaveManager.data.get("unlocked_levels", 1)
	var cols = 5
	var start_x = 200
	var start_y = 180
	var spacing_x = 180
	var spacing_y = 200

	for i in LEVEL_IDS.size():
		var level_id = LEVEL_IDS[i]
		var col = i % cols
		var row = i / cols
		var pos = Vector2(start_x + col * spacing_x, start_y + row * spacing_y)

		var is_unlocked = (i + 1) <= unlocked
		var is_current = (i + 1) == unlocked

		var tex_path = "res://assets Nikita/levels/level_current.png"
		if is_current:
			tex_path = "res://assets Nikita/levels/level_current.png"
		elif is_unlocked:
			tex_path = "res://assets Nikita/levels/level_unlocked.png"
		else:
			tex_path = "res://assets Nikita/levels/level_locked.png"

		if ResourceLoader.exists(tex_path):
			var btn = TextureButton.new()
			btn.texture_normal = load(tex_path)
			btn.position = pos
			if is_unlocked:
				btn.pressed.connect(_on_level_pressed.bind(level_id))
			add_child(btn)

		var label = Label.new()
		label.text = "Уровень %d" % [i + 1]
		label.position = pos + Vector2(20, 100)
		label.modulate = Color.WHITE if is_unlocked else Color(0.4, 0.4, 0.4)
		add_child(label)


func _add_background(path: String):
	if ResourceLoader.exists(path):
		var bg = Sprite2D.new()
		bg.texture = load(path)
		bg.position = Vector2(640, 360)
		bg.scale = Vector2(1280.0 / bg.texture.get_width(), 720.0 / bg.texture.get_height())
		add_child(bg)


func _add_button(path: String, pos: Vector2, callback: Callable):
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		var btn = TextureButton.new()
		btn.texture_normal = tex
		btn.position = pos - tex.get_size() * 0.5
		btn.pressed.connect(callback)
		add_child(btn)


func _on_back_pressed():
	AudioManager.play_sfx("res://assets/audio/click.wav")
	GameManager.go_to_scene("res://scenes/main_menu.tscn")


func _on_level_pressed(level_id: String):
	AudioManager.play_sfx("res://assets/audio/click.wav")
	GameManager.last_result["next_level"] = level_id
	GameManager.go_to_scene("res://scenes/preparation.tscn")
