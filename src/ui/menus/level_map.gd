extends Node2D


func _ready():
    _add_background("res://assets Nikita/backgrounds/bg_levels.png")
    _add_button("res://assets Nikita/buttons/button_back.png", Vector2(80, 650), _on_back_pressed)

    var level_btn = TextureButton.new()
    level_btn.texture_normal = load("res://assets Nikita/levels/level_current.png")
    level_btn.position = Vector2(500, 280)
    level_btn.pressed.connect(_on_level_pressed)
    add_child(level_btn)

    var level_label = Label.new()
    level_label.text = "Уровень 1"
    level_label.position = Vector2(520, 380)
    add_child(level_label)


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


func _on_level_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/preparation.tscn")
