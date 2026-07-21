class_name EggEntity
extends Node2D

var egg_config: EggConfig
var hp: int
var max_hp: int
var grid_pos: Vector2i

signal destroyed(egg: EggEntity)


func setup(config: EggConfig, pos: Vector2i):
    egg_config = config
    hp = config.hp
    max_hp = config.hp
    grid_pos = pos
    _render()


func _render():
    var sprite = Sprite2D.new()
    if egg_config.sprite:
        sprite.texture = egg_config.sprite
    else:
        var id_num = egg_config.id.trim_prefix("egg_").to_int()
        var path = "res://assets Nikita/eggs/egg_%02d.png" % id_num
        if ResourceLoader.exists(path):
            sprite.texture = load(path)
    if sprite.texture:
        var tex_size = sprite.texture.get_size()
        if tex_size.x > 0 and tex_size.y > 0:
            var s = Field.CELL_SIZE / max(tex_size.x, tex_size.y)
            sprite.scale = Vector2(s, s)
    add_child(sprite)

    var bar = ColorRect.new()
    bar.name = "HPBar"
    bar.size = Vector2(Field.CELL_SIZE - 12, 6)
    bar.position = Vector2(-Field.CELL_SIZE * 0.5 + 6, Field.CELL_SIZE * 0.5 - 10)
    bar.color = Color.GREEN
    add_child(bar)

    var bar_bg = ColorRect.new()
    bar_bg.name = "HPBarBG"
    bar_bg.size = bar.size
    bar_bg.position = bar.position
    bar_bg.color = Color.DARK_GREEN
    bar_bg.show_behind_parent = true
    add_child(bar_bg)


func take_damage(amount: int):
    hp -= amount
    _update_hp_bar()
    if hp <= 0:
        hp = 0
        destroyed.emit(self)


func _update_hp_bar():
    var bar = get_node("HPBar") as ColorRect
    if bar:
        var ratio = float(hp) / float(max_hp)
        bar.size.x = (Field.CELL_SIZE - 12) * ratio
        if ratio > 0.5:
            bar.color = Color.GREEN
        elif ratio > 0.25:
            bar.color = Color.YELLOW
        else:
            bar.color = Color.RED
