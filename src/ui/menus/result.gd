extends Node2D

var is_victory: bool = false
var _crystals_earned: int = 0


func _ready():
    is_victory = GameManager.last_result.get("victory", false)
    _crystals_earned = EconomyManager.crystals

    var bg_path = "res://assets Nikita/backgrounds/bg_result.png"
    if is_victory and ResourceLoader.exists("res://assets Nikita/backgrounds/bg_menu.png"):
        bg_path = "res://assets Nikita/backgrounds/bg_menu.png"
    if ResourceLoader.exists(bg_path):
        var bg = Sprite2D.new()
        bg.texture = load(bg_path)
        add_child(bg)

    var text = "ПОБЕДА!" if is_victory else "ПОРАЖЕНИЕ"
    var label = Label.new()
    label.text = text
    label.position = Vector2(540, 250)
    label.scale = Vector2(3, 3)
    if is_victory:
        label.modulate = Color.GREEN
    else:
        label.modulate = Color.RED
    add_child(label)

    if is_victory:
        var crystal_label = Label.new()
        crystal_label.text = "Кристаллов получено: %d" % _crystals_earned
        crystal_label.position = Vector2(540, 340)
        crystal_label.scale = Vector2(1.5, 1.5)
        add_child(crystal_label)

        var next_btn = _make_button(load("res://assets Nikita/buttons/button_play.png"), Vector2(640, 450))
        next_btn.pressed.connect(_on_next_pressed)
        add_child(next_btn)
    else:
        var retry_path = "res://assets Nikita/buttons/button_retry.png"
        if ResourceLoader.exists(retry_path):
            var retry_btn = _make_button(load(retry_path), Vector2(540, 450))
            retry_btn.pressed.connect(_on_retry_pressed)
            add_child(retry_btn)

        var back_path = "res://assets Nikita/buttons/button_back.png"
        if ResourceLoader.exists(back_path):
            var back_btn = _make_button(load(back_path), Vector2(740, 450))
            back_btn.pressed.connect(_on_back_pressed)
            add_child(back_btn)


func _make_button(texture: Texture2D, pos: Vector2) -> TextureButton:
    var btn = TextureButton.new()
    btn.texture_normal = texture
    btn.position = pos - texture.get_size() * 0.5
    return btn


func _on_next_pressed():
    GameManager.go_to_scene("res://scenes/level_map.tscn")


func _on_retry_pressed():
    GameManager.go_to_scene("res://scenes/game.tscn")


func _on_back_pressed():
    GameManager.go_to_scene("res://scenes/level_map.tscn")
