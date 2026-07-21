extends Control

enum DragMode { NONE, FROM_RESERVE, FROM_FIELD }

var mode: int = DragMode.NONE
var drag_config: SoldierConfig
var drag_source_side: int = -1
var drag_source_slot: int = -1
var preview_node: Control

signal soldier_placed(soldier_config: SoldierConfig, side: int, slot: int)
signal soldier_moved(from_side: int, from_slot: int, to_side: int, to_slot: int)
signal soldier_returned(soldier_config: SoldierConfig, side: int, slot: int)
signal soldier_sold(side: int, slot: int)


func start_reserve_drag(config: SoldierConfig):
    mode = DragMode.FROM_RESERVE
    drag_config = config
    _show_preview()


func start_field_drag(side: int, slot: int):
    mode = DragMode.FROM_FIELD
    drag_source_side = side
    drag_source_slot = slot
    _show_preview()


func cancel_drag():
    mode = DragMode.NONE
    drag_config = null
    drag_source_side = -1
    drag_source_slot = -1
    _hide_preview()


func is_dragging() -> bool:
    return mode != DragMode.NONE


func _show_preview():
    if not preview_node:
        preview_node = ColorRect.new()
        preview_node.size = Vector2(40, 40)
        preview_node.color = Color(1, 1, 0, 0.5)
        add_child(preview_node)
    preview_node.visible = true
    preview_node.position = get_global_mouse_position()


func _hide_preview():
    if preview_node:
        preview_node.visible = false


func _input(event):
    if not is_dragging():
        return
    if event is InputEventMouseMotion:
        if preview_node:
            preview_node.position = get_global_mouse_position()
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            if mode == DragMode.FROM_RESERVE and drag_config:
                cancel_drag()
            elif mode == DragMode.FROM_FIELD:
                cancel_drag()
