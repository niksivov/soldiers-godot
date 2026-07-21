extends Node

var field: Node2D
var active_soldiers: Array = []
var _fire_types: Dictionary = {}


func setup(field_node: Node2D):
    field = field_node
    _fire_types["bullet"] = FireTypeBullet.new()
    _fire_types["laser"] = FireTypeLaser.new()
    _fire_types["grenade"] = FireTypeGrenade.new()
    _fire_types["rocket"] = FireTypeRocket.new()


func register_soldier(soldier: SoldierEntity):
    soldier.set_meta("cooldown_timer", 0.0)
    active_soldiers.append(soldier)


func unregister_soldier(soldier: SoldierEntity):
    active_soldiers.erase(soldier)


func _process(delta):
    for soldier in active_soldiers:
        if not is_instance_valid(soldier):
            active_soldiers.erase(soldier)
            continue

        if not soldier.has_meta("cooldown_timer"):
            soldier.set_meta("cooldown_timer", 0.0)

        var timer = soldier.get_meta("cooldown_timer")
        timer -= delta
        soldier.set_meta("cooldown_timer", timer)

        if timer > 0.0:
            continue

        var targets = field.get_eggs_in_range(soldier.side, soldier.slot_index, soldier.range_cells)
        if targets.is_empty():
            continue

        var nearest = targets[0]

        var fire_type = _fire_types.get(soldier.fire_type_name)
        if fire_type:
            fire_type.execute(soldier, nearest.pos, field)
            soldier.set_meta("cooldown_timer", soldier.reload_time)
            AudioManager.play_sfx("res://assets/audio/shoot.wav")


func _get_fire_type(type_name: String):
    return _fire_types.get(type_name, _fire_types["bullet"])
