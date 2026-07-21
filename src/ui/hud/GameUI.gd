extends Control

@export var timer_label: Label
@export var coin_label: Label
@export var reserve_panel: VBoxContainer
@export var sell_rect: ColorRect

var interaction: Node
var field: Node2D
var _soldier_buttons: Array = []


func setup(interaction_node: Node, field_node: Node2D, level_config: LevelConfig):
    interaction = interaction_node
    field = field_node

    EconomyManager.coins_changed.connect(_on_coins_changed)
    coin_label.text = str(EconomyManager.coins)

    _build_reserve_ui(level_config.starting_reserves)
    _setup_sell_zone()


func _on_coins_changed(value: int):
    coin_label.text = str(value)


func update_timer(time_left: float):
    timer_label.text = str(ceil(time_left))


func _build_reserve_ui(reserves: Array):
    for child in _soldier_buttons:
        child.queue_free()
    _soldier_buttons.clear()

    for entry in reserves:
        var cfg = entry.soldier_config
        var container = HBoxContainer.new()
        container.size_flags_horizontal = SIZE_EXPAND

        var icon = TextureRect.new()
        icon.custom_minimum_size = Vector2(36, 36)
        icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
        if cfg.icon:
            icon.texture = cfg.icon
        container.add_child(icon)

        var label = Label.new()
        label.name = "CountLabel"
        label.text = "%s x%d" % [cfg.display_name, entry.count]
        container.add_child(label)

        var btn = Button.new()
        btn.flat = true
        btn.size_flags_horizontal = SIZE_EXPAND
        btn.pressed.connect(_on_reserve_clicked.bind(cfg))
        container.add_child(btn)

        reserve_panel.add_child(container)
        _soldier_buttons.append(container)

    interaction.set_reserve(reserves)


func _on_reserve_clicked(cfg: SoldierConfig):
    interaction.try_start_placement(cfg)


func _setup_sell_zone():
    pass
