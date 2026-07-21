extends Node2D

var level_config: LevelConfig


func _ready():
    var bg = Sprite2D.new()
    bg.texture = load("res://assets Nikita/backgrounds/bg_menu.png")
    add_child(bg)

    level_config = preload("res://assets/configs/level_01.tres")

    var label = Label.new()
    label.text = "Уровень 1: %s" % level_config.display_name
    label.position = Vector2(500, 200)
    label.scale = Vector2(2, 2)
    add_child(label)

    var info = Label.new()
    info.text = "Время: %d сек\nСтартовые монеты: %d\nНаграда: %d кристаллов\n\nЯйца:" % [level_config.time_limit, level_config.starting_coins, level_config.crystal_reward]
    info.position = Vector2(500, 280)
    add_child(info)

    var egg_counts = {}
    for w in level_config.waves:
        var eid = w.egg_config.display_name
        egg_counts[eid] = egg_counts.get(eid, 0) + 1

    var idx = 0
    for eid in egg_counts:
        var el = Label.new()
        el.text = "  %s x%d" % [eid, egg_counts[eid]]
        el.position = Vector2(500, 420 + idx * 25)
        add_child(el)
        idx += 1

    var play_btn = _make_button(load("res://assets Nikita/buttons/button_play.png"), Vector2(640, 550))
    play_btn.pressed.connect(_on_play_pressed)
    add_child(play_btn)


func _make_button(texture: Texture2D, pos: Vector2) -> TextureButton:
    var btn = TextureButton.new()
    btn.texture_normal = texture
    btn.position = pos - texture.get_size() * 0.5
    return btn


func _on_play_pressed():
    GameManager.go_to_scene("res://scenes/game.tscn")
