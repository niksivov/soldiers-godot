extends Node

const SAVE_PATH: String = "user://save.json"

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


func save():
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()


func load_save():
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        var json = JSON.new()
        if json.parse(file.get_as_text()) == OK:
            var loaded = json.data
            for key in loaded:
                if key in data:
                    data[key] = loaded[key]
        file.close()
