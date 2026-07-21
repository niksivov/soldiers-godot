class_name FireTypeRocket
extends FireTypeBase

func execute(shooter, target_grid_pos: Vector2i, field_node) -> bool:
    var egg = field_node.get_egg_at(target_grid_pos)
    if egg and is_instance_valid(egg):
        egg.take_damage(shooter.damage)
        return true
    return false
