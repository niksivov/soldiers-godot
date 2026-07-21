class_name FireTypeLaser
extends FireTypeBase

func execute(shooter, target_grid_pos: Vector2i, field_node) -> bool:
    var eggs = field_node.get_eggs_on_line(target_grid_pos, shooter.side)
    var hit_any = false
    for egg in eggs:
        if is_instance_valid(egg):
            egg.take_damage(shooter.damage)
            hit_any = true
    return hit_any
