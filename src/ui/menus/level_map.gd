extends Node2D


func _ready():
    var bg_path = "res://assets Nikita/backgrounds/bg_levels.png"
    if ResourceLoader.exists(bg_path):
        var bg = Sprite2D.new()
        bg.texture = load(bg_path)
        add_child(bg)

    var back_path = "res://assets Nikita/buttons/button_back.png"
    if ResourceLoader.exists(back_path):
        var back_btn = TextureButton.new()
        back_btn.texture_normal = load(back_path)
        back_btn.position = Vector2(50, 620)
        back_btn.pressed.connect(_on_back_pressed)
        add_child(back_btn)

    var level_btn = TextureButton.new()
    level_btn.texture_normal = load("res://assets Nikita/levels/level_current.png")
    level_btn.position = Vector2(500, 300)
    level_btn.pressed.connect(_on_level_pressed)
    add_child(level_btn)

    var level_label = Label.new()
    level_label.text = "Уровень 1"
    level_label.position = Vector2(520, 400)
    add_child(level_label)


func _on_back_pressed():
    GameManager.go_to_scene("res://scenes/main_menu.tscn")


func _on_level_pressed():
    GameManager.go_to_scene("res://scenes/preparation.tscn")
