extends Node2D


func _ready():
    var bg = Sprite2D.new()
    var bg_path = "res://assets Nikita/backgrounds/bg_menu.png"
    if ResourceLoader.exists(bg_path):
        bg.texture = load(bg_path)
    add_child(bg)

    var logo_path = "res://assets Nikita/logo/logo.png"
    if ResourceLoader.exists(logo_path):
        var logo = Sprite2D.new()
        logo.texture = load(logo_path)
        logo.position = Vector2(640, 150)
        add_child(logo)

    var play_btn_path = "res://assets Nikita/buttons/button_play.png"
    if ResourceLoader.exists(play_btn_path):
        var play_btn = _make_button(load(play_btn_path), Vector2(640, 350))
        play_btn.pressed.connect(_on_play_pressed)
        add_child(play_btn)

    var shop_btn_path = "res://assets Nikita/buttons/button_shop.png"
    if ResourceLoader.exists(shop_btn_path):
        var shop_btn = _make_button(load(shop_btn_path), Vector2(640, 430))
        shop_btn.pressed.connect(_on_shop_pressed)
        add_child(shop_btn)

    var settings_btn_path = "res://assets Nikita/buttons/button_settings.png"
    if ResourceLoader.exists(settings_btn_path):
        var settings_btn = _make_button(load(settings_btn_path), Vector2(640, 510))
        settings_btn.pressed.connect(_on_settings_pressed)
        add_child(settings_btn)


func _make_button(texture: Texture2D, pos: Vector2) -> TextureButton:
    var btn = TextureButton.new()
    btn.texture_normal = texture
    btn.position = pos - texture.get_size() * 0.5
    return btn


func _on_play_pressed():
    GameManager.go_to_scene("res://scenes/preparation.tscn")


func _on_shop_pressed():
    GameManager.go_to_scene("res://scenes/shop.tscn")


func _on_settings_pressed():
    GameManager.go_to_scene("res://scenes/settings.tscn")
