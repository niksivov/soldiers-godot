extends Node2D

const CELL_SIZE: int = 56
const GRID_SIZE: int = 10

enum Side { TOP, BOTTOM, LEFT, RIGHT }

var grid: Array = []
var perimeter: Array = []
var cell_sprites: Array = []

signal egg_placed(grid_pos: Vector2i)
signal egg_removed(grid_pos: Vector2i)
signal soldier_placed(side: int, slot: int)
signal soldier_removed(side: int, slot: int)


func _ready():
    _init_grid()
    _init_perimeter()
    _render()


func _init_grid():
    grid.clear()
    for x in GRID_SIZE:
        grid.append([])
        for y in GRID_SIZE:
            grid[x].append(null)


func _init_perimeter():
    perimeter.clear()
    for s in 4:
        perimeter.append([])
        for i in GRID_SIZE:
            perimeter[s].append(null)


func _render():
    for x in GRID_SIZE:
        cell_sprites.append([])
        for y in GRID_SIZE:
            var cell = Sprite2D.new()
            cell.texture = load("res://assets Nikita/cells/cell_empty.png")
            cell.position = Vector2((x + 1) * CELL_SIZE, (y + 1) * CELL_SIZE)
            add_child(cell)
            cell_sprites[x].append(cell)

    for i in GRID_SIZE:
        _create_slot(Side.TOP, i, Vector2((i + 1) * CELL_SIZE, 0))
        _create_slot(Side.BOTTOM, i, Vector2((i + 1) * CELL_SIZE, (GRID_SIZE + 1) * CELL_SIZE))
        _create_slot(Side.LEFT, i, Vector2(0, (i + 1) * CELL_SIZE))
        _create_slot(Side.RIGHT, i, Vector2((GRID_SIZE + 1) * CELL_SIZE, (i + 1) * CELL_SIZE))


func _create_slot(side: int, index: int, pos: Vector2):
    var area = Area2D.new()
    area.name = "Slot_%s_%d" % [Side.keys()[side], index]
    area.position = pos
    area.set_meta(&"side", side)
    area.set_meta(&"slot_index", index)

    var sprite = Sprite2D.new()
    sprite.texture = load("res://assets Nikita/cells/cell_field.png")
    area.add_child(sprite)

    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(CELL_SIZE, CELL_SIZE)
    collision.shape = shape
    area.add_child(collision)

    add_child(area)


func get_random_free_cell() -> Vector2i:
    var free: Array = []
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            if grid[x][y] == null:
                free.append(Vector2i(x, y))
    if free.is_empty():
        return Vector2i(-1, -1)
    free.shuffle()
    return free[0]


func place_egg(grid_pos: Vector2i, egg_node: Node2D) -> bool:
    if not _is_in_grid(grid_pos):
        return false
    if grid[grid_pos.x][grid_pos.y] != null:
        return false
    grid[grid_pos.x][grid_pos.y] = egg_node
    var visual_pos = Vector2((grid_pos.x + 1) * CELL_SIZE, (grid_pos.y + 1) * CELL_SIZE)
    egg_node.position = visual_pos
    add_child(egg_node)
    egg_placed.emit(grid_pos)
    return true


func remove_egg(grid_pos: Vector2i) -> Node2D:
    if not _is_in_grid(grid_pos):
        return null
    var egg = grid[grid_pos.x][grid_pos.y]
    if egg:
        grid[grid_pos.x][grid_pos.y] = null
        remove_child(egg)
        egg_removed.emit(grid_pos)
    return egg


func get_egg_at(grid_pos: Vector2i):
    if not _is_in_grid(grid_pos):
        return null
    return grid[grid_pos.x][grid_pos.y]


func is_cell_free(grid_pos: Vector2i) -> bool:
    if not _is_in_grid(grid_pos):
        return false
    return grid[grid_pos.x][grid_pos.y] == null


func is_slot_free(side: int, index: int) -> bool:
    if not _is_valid_slot(side, index):
        return false
    return perimeter[side][index] == null


func occupy_slot(side: int, index: int, soldier_node: Node2D) -> bool:
    if not is_slot_free(side, index):
        return false
    perimeter[side][index] = soldier_node

    var positions = {
        Side.TOP: Vector2((index + 1) * CELL_SIZE, 0),
        Side.BOTTOM: Vector2((index + 1) * CELL_SIZE, (GRID_SIZE + 1) * CELL_SIZE),
        Side.LEFT: Vector2(0, (index + 1) * CELL_SIZE),
        Side.RIGHT: Vector2((GRID_SIZE + 1) * CELL_SIZE, (index + 1) * CELL_SIZE)
    }
    soldier_node.position = positions[side]
    soldier_node.set_meta(&"side", side)
    soldier_node.set_meta(&"slot_index", index)

    var rotation_map = {
        Side.TOP: 0.0,
        Side.BOTTOM: PI,
        Side.LEFT: PI * 0.5,
        Side.RIGHT: PI * -0.5
    }
    soldier_node.rotation = rotation_map[side]

    add_child(soldier_node)
    soldier_placed.emit(side, index)
    return true


func free_slot(side: int, index: int) -> Node2D:
    if not _is_valid_slot(side, index):
        return null
    var soldier = perimeter[side][index]
    if soldier:
        perimeter[side][index] = null
        soldier_removed.emit(side, index)
        remove_child(soldier)
    return soldier


func get_eggs_on_line(side: int, index: int) -> Array:
    var eggs_on_line: Array = []
    match side:
        Side.TOP, Side.BOTTOM:
            var col = index
            for row in GRID_SIZE:
                var pos = Vector2i(col, row)
                var egg = get_egg_at(pos)
                if egg:
                    eggs_on_line.append(egg)
        Side.LEFT, Side.RIGHT:
            var row = index
            for col in GRID_SIZE:
                var pos = Vector2i(col, row)
                var egg = get_egg_at(pos)
                if egg:
                    eggs_on_line.append(egg)
    return eggs_on_line


func get_eggs_in_range(side: int, slot_index: int, range_cells: int) -> Array:
    var target_line: Array = []
    match side:
        Side.TOP:
            var col = slot_index
            for row in GRID_SIZE:
                if row < range_cells:
                    var pos = Vector2i(col, row)
                    var egg = get_egg_at(pos)
                    if egg:
                        target_line.append({ "egg": egg, "pos": pos, "dist": row + 1 })
        Side.BOTTOM:
            var col = slot_index
            for row in range(GRID_SIZE - 1, -1, -1):
                var dist = GRID_SIZE - row
                if dist <= range_cells:
                    var pos = Vector2i(col, row)
                    var egg = get_egg_at(pos)
                    if egg:
                        target_line.append({ "egg": egg, "pos": pos, "dist": dist })
        Side.LEFT:
            var row = slot_index
            for col in GRID_SIZE:
                if col < range_cells:
                    var pos = Vector2i(col, row)
                    var egg = get_egg_at(pos)
                    if egg:
                        target_line.append({ "egg": egg, "pos": pos, "dist": col + 1 })
        Side.RIGHT:
            var row = slot_index
            for col in range(GRID_SIZE - 1, -1, -1):
                var dist = GRID_SIZE - col
                if dist <= range_cells:
                    var pos = Vector2i(col, row)
                    var egg = get_egg_at(pos)
                    if egg:
                        target_line.append({ "egg": egg, "pos": pos, "dist": dist })
    return target_line


func get_field_center() -> Vector2:
    var total = (GRID_SIZE + 2) * CELL_SIZE
    return Vector2(total * 0.5, total * 0.5)


func _is_in_grid(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE


func _is_valid_slot(side: int, index: int) -> bool:
    return side >= 0 and side < 4 and index >= 0 and index < GRID_SIZE


func get_egg_count() -> int:
    var count = 0
    for x in GRID_SIZE:
        for y in GRID_SIZE:
            if grid[x][y] != null:
                count += 1
    return count
