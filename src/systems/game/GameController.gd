extends Node

@export var field: Node2D
@export var spawner: Node
@export var combat_system: Node
@export var ui_layer: CanvasLayer

var current_level: LevelConfig
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false

signal victory()
signal defeat()
signal time_updated(time_left: float)

const LEVEL_PATH: String = "res://assets/configs/level_01.tres"
const RESULT_PATH: String = "res://scenes/result.tscn"


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    field.soldier_placed.connect(_on_soldier_placed)

    current_level = load(LEVEL_PATH)
    if current_level:
        _start_level()


func _start_level():
    if not current_level:
        return
    game_time = 0.0
    is_game_over = false
    is_paused = false

    EconomyManager.coins = current_level.starting_coins
    combat_system.setup(field)
    spawner.setup(field, current_level.waves)
    LevelManager.load_level(current_level.id)
    LevelManager.level_started.emit(current_level.id)


func _process(delta):
    if is_paused or is_game_over:
        return

    game_time += delta
    spawner.process_spawn(game_time)

    var time_left = max(0.0, current_level.time_limit - game_time)
    time_updated.emit(time_left)

    if time_left <= 0.0 and field.get_egg_count() == 0:
        _on_victory()
    elif time_left <= 0.0:
        _on_defeat()


func _on_soldier_placed(side: int, slot: int):
    var soldier_node = field.perimeter[side][slot]
    if soldier_node is SoldierEntity:
        combat_system.register_soldier(soldier_node)


func _on_victory():
    is_game_over = true
    EconomyManager.add_crystals(current_level.crystal_reward)
    LevelManager.complete_level(true)
    GameManager.go_to_scene_with_data(RESULT_PATH, { "victory": true })


func _on_defeat():
    is_game_over = true
    LevelManager.complete_level(false)
    GameManager.go_to_scene_with_data(RESULT_PATH, { "victory": false })


func pause():
    is_paused = true


func resume():
    is_paused = false
