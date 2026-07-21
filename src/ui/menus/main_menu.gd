extends Node2D


func _ready():
    AudioManager.play_music("res://assets Nikita/music/menu.mp3")
    _add_background("res://assets Nikita/backgrounds/bg_menu.png")
    _add_logo()
    _add_button("res://assets Nikita/buttons/button_play.png", Vector2(640, 380), _on_play_pressed)
    _add_button("res://assets Nikita/buttons/button_shop.png", Vector2(640, 460), _on_shop_pressed)
    _add_button("res://assets Nikita/buttons/button_settings.png", Vector2(640, 540), _on_settings_pressed)


func _add_background(path: String):
    if ResourceLoader.exists(path):
        var bg = Sprite2D.new()
        bg.texture = load(path)
        bg.position = Vector2(640, 360)
        bg.scale = Vector2(1280.0 / bg.texture.get_width(), 720.0 / bg.texture.get_height())
        add_child(bg)


func _add_logo():
    var path = "res://assets Nikita/logo/logo.png"
    if ResourceLoader.exists(path):
        var logo = Sprite2D.new()
        logo.texture = load(path)
        logo.position = Vector2(640, 160)
        add_child(logo)


func _add_button(path: String, pos: Vector2, callback: Callable):
    if ResourceLoader.exists(path):
        var tex = load(path) as Texture2D
        var btn = TextureButton.new()
        btn.texture_normal = tex
        btn.position = pos - tex.get_size() * 0.5
        btn.pressed.connect(callback)
        add_child(btn)


func _on_play_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/level_map.tscn")


func _on_shop_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/shop.tscn")


func _on_settings_pressed():
    AudioManager.play_sfx("res://assets/audio/click.wav")
    GameManager.go_to_scene("res://scenes/settings.tscn")
