extends Node

var field: Node2D
var spawned_count: int = 0
var total_to_spawn: int = 0
var _wave_queue: Array = []

signal all_spawned()
signal egg_spawned(egg_node: Node2D)


func setup(field_node: Node2D, waves: Array):
    field = field_node
    _wave_queue.clear()
    for wave in waves:
        _wave_queue.append({
            "time": wave.time,
            "egg_config": wave.egg_config,
            "spawned": false
        })
    _wave_queue.sort_custom(func(a, b): return a.time < b.time)
    total_to_spawn = _wave_queue.size()
    spawned_count = 0


func get_pending_wave_count() -> int:
    var count = 0
    for w in _wave_queue:
        if not w.spawned:
            count += 1
    return count


func process_spawn(elapsed: float):
    if _wave_queue.is_empty():
        return
    var next = _wave_queue[0]
    if elapsed >= next.time and not next.spawned:
        next.spawned = true
        _wave_queue.pop_front()
        _do_spawn(next.egg_config)
        if _wave_queue.is_empty():
            all_spawned.emit()


func _do_spawn(egg_config):
    var free_pos = field.get_random_free_cell()
    if free_pos == Vector2i(-1, -1):
        return

    var egg = EggEntity.new()
    egg.setup(egg_config, free_pos)
    field.place_egg(free_pos, egg)
    egg.destroyed.connect(_on_egg_destroyed.bind(egg))
    spawned_count += 1
    egg_spawned.emit(egg)


func _on_egg_destroyed(egg: EggEntity):
    EconomyManager.add_coins(egg.egg_config.reward_coins)
    egg.queue_free()
