extends Node

const RESULT_PATH: String = "res://scenes/result.tscn"
const LEVEL_PATHS: Dictionary = {
	"level_01": "res://assets/configs/level_01.tres",
	"level_02": "res://assets/configs/level_02.tres",
	"level_03": "res://assets/configs/level_03.tres"
}

var current_level: LevelConfig
var game_time: float = 0.0
var is_paused: bool = false
var is_game_over: bool = false
var _field: Node2D
var _spawner: Node
var _combat: Node
var _interaction: Control
var _game_ui: Control

signal victory()
signal defeat()
signal time_updated(time_left: float)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_background()
	_resolve_nodes()

	var level_id = GameManager.last_result.get("next_level", "level_01")
	var path = LEVEL_PATHS.get(level_id, "res://assets/configs/level_01.tres")
	current_level = load(path)
	if not current_level:
		current_level = load("res://assets/configs/level_01.tres")
	if not current_level:
		current_level = _make_default_level()

	if current_level:
		_start_level()


func _resolve_nodes():
	_field = $Field
	_spawner = $EggSpawner
	_combat = $CombatSystem
	_interaction = $GameInteraction
	_game_ui = $UILayer/GameUI


func _setup_background():
	var bg = get_node_or_null("Background") as Sprite2D
	if bg and bg.texture:
		var tw = bg.texture.get_width()
		var th = bg.texture.get_height()
		if tw > 0 and th > 0:
			bg.scale = Vector2(1280.0 / tw, 720.0 / th)


func _make_default_level() -> LevelConfig:
	var cfg = LevelConfig.new()
	cfg.id = "level_01"
	cfg.display_name = "Уровень 1"
	cfg.time_limit = 60.0
	cfg.starting_coins = 500
	cfg.crystal_reward = 10

	var sr = StartingReserve.new()
	sr.soldier_config = load("res://assets/configs/soldier_rifleman.tres")
	sr.count = 8
	cfg.starting_reserves = [sr]
	cfg.waves = []
	return cfg


func _start_level():
	if not current_level:
		return
	AudioManager.play_music("res://assets Nikita/music/game.mp3")
	game_time = 0.0
	is_game_over = false
	is_paused = false

	EconomyManager.coins = current_level.starting_coins

	if _combat and _combat.has_method("setup"):
		_combat.setup(_field)

	var sell_rect = Rect2(780, 550, 200, 100)
	if _game_ui:
		var sz = _game_ui.get_node_or_null("SellZone")
		if sz:
			sell_rect = Rect2(sz.global_position, sz.size)

	if _interaction and _interaction.has_method("setup"):
		_interaction.setup(_field, _combat, sell_rect)

	if _game_ui and _game_ui.has_method("setup"):
		_game_ui.setup(_interaction, _field, current_level)

	if _spawner and _spawner.has_method("setup"):
		_spawner.setup(_field, current_level.waves)

	LevelManager.load_level(current_level.id)

	if _interaction and _interaction.has_method("set_reserve"):
		_interaction.set_reserve(current_level.starting_reserves)

	var initial_time = current_level.time_limit
	time_updated.emit(initial_time)
	if _game_ui and _game_ui.has_method("update_timer"):
		_game_ui.update_timer(initial_time)


func _process(delta):
	if is_paused or is_game_over:
		return

	game_time += delta
	if _spawner and _spawner.has_method("process_spawn"):
		_spawner.process_spawn(game_time)

	var time_left = max(0.0, current_level.time_limit - game_time)
	time_updated.emit(time_left)

	if _game_ui and _game_ui.has_method("update_timer"):
		_game_ui.update_timer(time_left)

	if _field and _field.has_method("get_egg_count") and _field.get_egg_count() == 0:
		if _spawner and _spawner.has_method("get_pending_wave_count") and _spawner.get_pending_wave_count() == 0:
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
