extends Node

@export var field: Node2D
@export var spawner: Node
@export var combat_system: Node
@export var interaction: Control
@export var ui_layer: CanvasLayer
@export var game_ui: Control

var current_level: LevelConfig
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false

signal victory()
signal defeat()
signal time_updated(time_left: float)

const RESULT_PATH: String = "res://scenes/result.tscn"
const LEVEL_PATHS: Dictionary = {
	"level_01": "res://assets/configs/level_01.tres",
	"level_02": "res://assets/configs/level_02.tres",
	"level_03": "res://assets/configs/level_03.tres"
}


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    _setup_background()

    var level_id = GameManager.last_result.get("next_level", "level_01")
    var path = LEVEL_PATHS.get(level_id, "res://assets/configs/level_01.tres")
    if ResourceLoader.exists(path):
        current_level = load(path)
    else:
        current_level = load("res://assets/configs/level_01.tres")

    if current_level:
        _start_level()


func _setup_background():
    var bg = get_node_or_null("Background") as Sprite2D
    if bg and bg.texture:
        var tex = bg.texture
        var tw = tex.get_width()
        var th = tex.get_height()
        if tw > 0 and th > 0:
            bg.scale = Vector2(1280.0 / tw, 720.0 / th)


func _start_level():
    if not current_level:
        return
    AudioManager.play_music("res://assets Nikita/music/game.mp3")
    game_time = 0.0
    is_game_over = false
    is_paused = false

    EconomyManager.coins = current_level.starting_coins
    combat_system.setup(field)

    var sell_global = game_ui.get_node("SellZone")
    var sell_rect = Rect2(sell_global.global_position, sell_global.size)
    interaction.setup(field, combat_system, sell_rect)

    if game_ui.has_method("setup"):
        game_ui.setup(interaction, field, current_level)

    spawner.setup(field, current_level.waves)
    LevelManager.load_level(current_level.id)

    interaction.set_reserve(current_level.starting_reserves)

    var initial_time = current_level.time_limit
    time_updated.emit(initial_time)
    if game_ui and game_ui.has_method("update_timer"):
        game_ui.update_timer(initial_time)


func _process(delta):
    if is_paused or is_game_over:
        return

    game_time += delta
    spawner.process_spawn(game_time)

    var time_left = max(0.0, current_level.time_limit - game_time)
    time_updated.emit(time_left)

    if game_ui and game_ui.has_method("update_timer"):
        game_ui.update_timer(time_left)

    if field.get_egg_count() == 0 and spawner.get_pending_wave_count() == 0:
        _on_victory()
    elif time_left <= 0.0:
        _on_defeat()


func _on_victory():
    is_game_over = true
    EconomyManager.add_crystals(current_level.crystal_reward)
    LevelManager.complete_level(true)

    var level_num = current_level.id.trim_prefix("level_").to_int()
    var unlocked = SaveManager.data.get("unlocked_levels", 1)
    if level_num >= unlocked:
        SaveManager.save_player_data("unlocked_levels", level_num + 1)
    SaveManager.mark_dirty()

    GameManager.go_to_scene_with_data(RESULT_PATH, { "victory": true, "next_level": current_level.id })


func _on_defeat():
    is_game_over = true
    LevelManager.complete_level(false)
    GameManager.go_to_scene_with_data(RESULT_PATH, { "victory": false })


func pause():
    is_paused = true


func resume():
    is_paused = false
