class_name FireTypeGrenade
extends FireTypeBase

func execute(shooter, target_grid_pos: Vector2i, field_node) -> bool:
    var main_egg = field_node.get_egg_at(target_grid_pos)
    if main_egg and is_instance_valid(main_egg):
        main_egg.take_damage(shooter.damage)
    for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
        var splash_pos = target_grid_pos + offset
        var splash_egg = field_node.get_egg_at(splash_pos)
        if splash_egg and is_instance_valid(splash_egg):
            splash_egg.take_damage(ceil(shooter.damage * 0.5))
    return main_egg != null
