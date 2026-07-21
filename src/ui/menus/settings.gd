extends Node2D


func _ready():
    var bg_path = "res://assets Nikita/backgrounds/bg_settings.png"
    if ResourceLoader.exists(bg_path):
        var bg = Sprite2D.new()
        bg.texture = load(bg_path)
        add_child(bg)

    var label = Label.new()
    label.text = "Настройки"
    label.position = Vector2(540, 100)
    label.scale = Vector2(2, 2)
    add_child(label)

    var back_path = "res://assets Nikita/buttons/button_back.png"
    if ResourceLoader.exists(back_path):
        var back_btn = TextureButton.new()
        back_btn.texture_normal = load(back_path)
        back_btn.position = Vector2(50, 620)
        back_btn.pressed.connect(_on_back_pressed)
        add_child(back_btn)


func _on_back_pressed():
    GameManager.go_to_scene("res://scenes/main_menu.tscn")
