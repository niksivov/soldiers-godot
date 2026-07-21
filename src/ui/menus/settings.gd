extends Node2D


func _ready():
    _add_background("res://assets Nikita/backgrounds/bg_settings.png")

    var label = Label.new()
    label.text = "Настройки"
    label.position = Vector2(540, 100)
    label.scale = Vector2(2, 2)
    add_child(label)

    _add_button("res://assets Nikita/buttons/button_back.png", Vector2(80, 650), _on_back_pressed)


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
