extends Control

enum State { IDLE, PLACING, MOVING }

var state: int = State.IDLE
var field: Node2D
var combat_system: Node

var _pending_config: SoldierConfig
var _moving_side: int = -1
var _moving_slot: int = -1
var _hovered_slot: Dictionary = {}
var _hovered_soldier: Node2D = null
var _placing_preview: ColorRect
var _sell_rect: Rect2
var _reserve: Dictionary = {}

signal soldier_placed(soldier: SoldierEntity)
signal soldier_sold(side: int, slot: int, refund: int)


func setup(field_node: Node2D, combat: Node, sell_rect: Rect2):
    field = field_node
    combat_system = combat
    _sell_rect = sell_rect


func set_reserve(reserves: Array):
    _reserve.clear()
    for r in reserves:
        _reserve[r.soldier_config.id] = {
            "config": r.soldier_config,
            "count": r.count
        }


func can_place(config: SoldierConfig) -> bool:
    var entry = _reserve.get(config.id)
    return entry and entry.count > 0 and EconomyManager.coins >= config.cost


func try_start_placement(config: SoldierConfig) -> bool:
    var entry = _reserve.get(config.id)
    if not entry or entry.count <= 0:
        return false
    if EconomyManager.coins < config.cost:
        return false

    if state != State.IDLE:
        cancel_placement()

    EconomyManager.spend_coins(config.cost)
    state = State.PLACING
    _pending_config = config
    _show_preview(config)
    return true


func try_start_move(side: int, slot: int) -> bool:
    if state != State.IDLE:
        return false
    if field.is_slot_free(side, slot):
        return false

    state = State.MOVING
    _moving_side = side
    _moving_slot = slot
    _show_move_preview()
    return true


func cancel_placement():
    if state == State.PLACING and _pending_config:
        EconomyManager.add_coins(_pending_config.cost)
    _reset()


func _reset():
    state = State.IDLE
    _pending_config = null
    _moving_side = -1
    _moving_slot = -1
    _hovered_soldier = null
    _hide_preview()


func _show_preview(config: SoldierConfig):
    if not _placing_preview:
        _placing_preview = ColorRect.new()
        _placing_preview.size = Vector2(Field.CELL_SIZE, Field.CELL_SIZE)
        _placing_preview.color = Color(1, 1, 0, 0.3)
        add_child(_placing_preview)
    _placing_preview.visible = true


func _show_move_preview():
    _show_preview(null)


func _hide_preview():
    if _placing_preview:
        _placing_preview.visible = false


func _unhandled_input(event):
    if event is InputEventMouseMotion:
        _hovered_slot = _get_slot_at_pos(event.position)
        _hovered_soldier = _get_soldier_at_pos(event.position)

        if state == State.PLACING and _placing_preview:
            if not _hovered_slot.is_empty():
                _placing_preview.position = _hovered_slot.screen_pos - Vector2(Field.CELL_SIZE * 0.5, Field.CELL_SIZE * 0.5)
                _placing_preview.color = Color(0, 1, 0, 0.3) if _hovered_slot.free else Color(1, 0, 0, 0.3)
            else:
                _placing_preview.global_position = event.position
                _placing_preview.color = Color(1, 1, 0, 0.3)

    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            _on_click_release()
        elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
            if state != State.IDLE:
                cancel_placement()


func _on_click_release():
    match state:
        State.IDLE:
            if _hovered_soldier and is_instance_valid(_hovered_soldier):
                var side = _hovered_soldier.get_meta("side", -1)
                var slot = _hovered_soldier.get_meta("slot_index", -1)
                if side >= 0:
                    try_start_move(side, slot)

        State.PLACING:
            if _pending_config and not _hovered_slot.is_empty() and _hovered_slot.free:
                _place_soldier(_pending_config, _hovered_slot.side, _hovered_slot.index)
                state = State.IDLE
                _pending_config = null
                _hide_preview()

        State.MOVING:
            if not _hovered_slot.is_empty() and _hovered_slot.free:
                _move_soldier(_moving_side, _moving_slot, _hovered_slot.side, _hovered_slot.index)
            elif _is_over_sell_zone():
                _sell_soldier(_moving_side, _moving_slot)
            _reset()


func _get_slot_at_pos(screen_pos: Vector2) -> Dictionary:
    if not field:
        return {}

    var field_global = field.global_position
    var cs = Field.CELL_SIZE
    var gs = Field.GRID_SIZE

    var local_x = screen_pos.x - field_global.x
    var local_y = screen_pos.y - field_global.y

    if local_x < 0 or local_x > (gs + 2) * cs:
        return {}
    if local_y < 0 or local_y > (gs + 2) * cs:
        return {}

    var col = int(local_x / cs)
    var row = int(local_y / cs)

    var side = -1
    var index = -1

    if row == 0 and col >= 1 and col <= gs:
        side = Field.Side.TOP
        index = col - 1
    elif row == gs + 1 and col >= 1 and col <= gs:
        side = Field.Side.BOTTOM
        index = col - 1
    elif col == 0 and row >= 1 and row <= gs:
        side = Field.Side.LEFT
        index = row - 1
    elif col == gs + 1 and row >= 1 and row <= gs:
        side = Field.Side.RIGHT
        index = row - 1

    if side < 0:
        return {}

    var free = field.is_slot_free(side, index)
    var screen = Vector2(field_global.x + col * cs, field_global.y + row * cs)

    return {
        "side": side,
        "index": index,
        "free": free,
        "screen_pos": screen
    }


func _get_soldier_at_pos(screen_pos: Vector2):
    var slot = _get_slot_at_pos(screen_pos)
    if slot.is_empty():
        return null
    if slot.free:
        return null
    var node = field.perimeter[slot.side][slot.index]
    if is_instance_valid(node):
        return node
    return null


func _place_soldier(config: SoldierConfig, side: int, slot: int):
    var soldier = SoldierEntity.new()
    soldier.setup(config)
    if field.occupy_slot(side, slot, soldier):
        combat_system.register_soldier(soldier)
        soldier_placed.emit(soldier)
        var entry = _reserve.get(config.id)
        if entry:
            entry.count -= 1


func _move_soldier(from_side: int, from_slot: int, to_side: int, to_slot: int):
    var soldier = field.free_slot(from_side, from_slot)
    if soldier:
        if field.occupy_slot(to_side, to_slot, soldier):
            soldier.set_meta("side", to_side)
            soldier.set_meta("slot_index", to_slot)
            soldier.side = to_side
            soldier.slot_index = to_slot


func _sell_soldier(side: int, slot: int):
    var soldier = field.perimeter[side][slot]
    if not soldier or not is_instance_valid(soldier):
        return
    if soldier is SoldierEntity:
        var refund = int(soldier.soldier_config.cost * 0.5)
        combat_system.unregister_soldier(soldier)
        field.free_slot(side, slot)
        EconomyManager.add_coins(refund)
        soldier_sold.emit(side, slot, refund)


func _is_over_sell_zone() -> bool:
    var mouse = get_global_mouse_position()
    return _sell_rect.has_point(mouse)
