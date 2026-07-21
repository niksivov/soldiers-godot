extends Node

var data: Dictionary = {
	"unlocked_levels": 1,
	"crystals": 0,
	"soldier_reserves": {},
	"soldier_upgrades": {},
	"settings": {
		"music_vol": 0.8,
		"sfx_vol": 0.8
	}
}

var _dirty: bool = false
var _save_cooldown: float = 0.0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_from_storage()


func mark_dirty():
	_dirty = true


func save_player_data(key: String, value):
	data[key] = value
	mark_dirty()


func _process(delta):
	if _dirty:
		_save_cooldown -= delta
		if _save_cooldown <= 0.0:
			_dirty = false
			_save_cooldown = 5.0
			_save_to_storage()


func _save_to_storage():
	if OS.has_feature("web"):
		YandexSDK.save_cloud(data)
	else:
		_save_local()


func _load_from_storage():
	if OS.has_feature("web"):
		_load_cloud()
	else:
		_load_local()


func _load_cloud():
	var cloud_data = await YandexSDK.load_cloud()
	if cloud_data and not cloud_data.is_empty():
		for key in cloud_data:
			if key in data:
				data[key] = cloud_data[key]
		_apply_data()


func _save_local():
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func _load_local():
	if not FileAccess.file_exists("user://save.json"):
		return
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var loaded = json.data
			for key in loaded:
				if key in data:
					data[key] = loaded[key]
		file.close()
	_apply_data()


func _apply_data():
	EconomyManager.crystals = data.get("crystals", 0)
	AudioManager.music_volume = data.get("settings", {}).get("music_vol", 0.8)
	AudioManager.sfx_volume = data.get("settings", {}).get("sfx_vol", 0.8)
