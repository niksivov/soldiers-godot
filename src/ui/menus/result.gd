extends Node2D

var is_victory: bool = false
var _crystals_earned: int = 0


func _ready():
    is_victory = GameManager.last_result.get("victory", false)
    _crystals_earned = EconomyManager.crystals

    if is_victory:
        AudioManager.play_sfx("res://assets/audio/level_complete.wav")
    else:
        AudioManager.play_sfx("res://assets/audio/error.wav")

    var bg_path = "res://assets Nikita/backgrounds/bg_result.png"
    if is_victory and ResourceLoader.exists("res://assets Nikita/backgrounds/bg_menu.png"):
        bg_path = "res://assets Nikita/backgrounds/bg_menu.png"
    _add_background(bg_path)

    var text = "ПОБЕДА!" if is_victory else "ПОРАЖЕНИЕ"
    var label = Label.new()
    label.text = text
    label.position = Vector2(540, 240)
    label.scale = Vector2(3, 3)
    label.modulate = Color.GREEN if is_victory else Color.RED
    add_child(label)

    if is_victory:
        var crystal_label = Label.new()
        crystal_label.text = "Кристаллов получено: %d" % _crystals_earned
        crystal_label.position = Vector2(540, 340)
        crystal_label.scale = Vector2(1.5, 1.5)
        add_child(crystal_label)

        _add_button("res://assets Nikita/buttons/button_play.png", Vector2(640, 450), _on_next_pressed)
    else:
        _add_button("res://assets Nikita/buttons/button_retry.png", Vector2(540, 450), _on_retry_pressed)
        _add_button("res://assets Nikita/buttons/button_back.png", Vector2(740, 450), _on_back_pressed)


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


func _on_next_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    var current = GameManager.last_result.get("next_level", "level_01")
    var num = current.trim_prefix("level_").to_int()
    var next = "level_%02d" % [num + 1]
    GameManager.last_result["next_level"] = next
    GameManager.go_to_scene("res://scenes/preparation.tscn")


func _on_retry_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/game.tscn")


func _on_back_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/level_map.tscn")
