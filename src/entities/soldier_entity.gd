class_name SoldierEntity
extends Node2D

var soldier_config: SoldierConfig
var side: int:
    set(value):
        side = value
        _update_rotation()

var slot_index: int
var damage: int
var reload_time: float
var range_cells: int
var fire_type_name: String
var upgrade_level: int = 0


func setup(config: SoldierConfig):
    soldier_config = config
    damage = config.damage
    reload_time = config.reload_time
    range_cells = config.range
    fire_type_name = config.fire_type
    _render()


func _render():
    var sprite = Sprite2D.new()
    if soldier_config.sprite:
        sprite.texture = soldier_config.sprite
    else:
        var id_num = soldier_config.id
        var idx = 0
        var soldier_ids = ["rifleman", "machinegunner", "sniper", "laser", "grenadier", "rocket"]
        for i in soldier_ids.size():
            if soldier_ids[i] == id_num:
                idx = i + 1
                break
        var path = "res://assets Nikita/soldiers/soldier_%02d_idle.png" % idx
        if ResourceLoader.exists(path):
            sprite.texture = load(path)
    sprite.scale = Vector2(0.5, 0.5)
    add_child(sprite)


func _update_rotation():
    var rotation_map = {
        Field.Side.TOP: 0.0,
        Field.Side.BOTTOM: PI,
        Field.Side.LEFT: PI * 0.5,
        Field.Side.RIGHT: PI * -0.5
    }
    rotation = rotation_map.get(side, 0.0)
