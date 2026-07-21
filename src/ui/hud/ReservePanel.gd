extends Control

var entries: Dictionary = {}
var _entry_nodes: Array = []

signal reserve_selected(soldier_config: SoldierConfig)


func setup(reserves: Array):
    for child in _entry_nodes:
        child.queue_free()
    _entry_nodes.clear()
    entries.clear()

    var y_offset = 0
    for entry in reserves:
        var cfg = entry.soldier_config
        var container = HBoxContainer.new()
        container.size_flags_horizontal = SIZE_EXPAND
        add_child(container)

        var icon = TextureRect.new()
        icon.texture = cfg.icon
        icon.custom_minimum_size = Vector2(36, 36)
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        container.add_child(icon)

        var label = Label.new()
        label.text = "%s x%d" % [cfg.display_name, entry.count]
        container.add_child(label)

        entries[cfg.id] = { "config": cfg, "count": entry.count, "node": label }
        _entry_nodes.append(container)

        var btn = Button.new()
        btn.flat = true
        btn.size = container.size
        container.add_child(btn)
        btn.pressed.connect(_on_entry_clicked.bind(cfg))


func _on_entry_clicked(cfg: SoldierConfig):
    var entry = entries.get(cfg.id)
    if entry and entry.count > 0:
        reserve_selected.emit(cfg)
