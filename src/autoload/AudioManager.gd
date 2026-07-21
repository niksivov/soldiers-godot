extends Node

var music_volume: float = 0.8:
    set(value):
        music_volume = value
        _update_music_volume()

var sfx_volume: float = 0.8:
    set(value):
        sfx_volume = value
        _update_sfx_volume()

var _music_player: AudioStreamPlayer
var _sfx_players: Array = []
var _current_music: String = ""


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    _music_player = AudioStreamPlayer.new()
    _music_player.name = "MusicPlayer"
    add_child(_music_player)

    for i in 4:
        var p = AudioStreamPlayer2D.new()
        p.name = "SFXPlayer_%d" % i
        add_child(p)
        _sfx_players.append(p)


func play_music(path: String):
    if _current_music == path and _music_player.playing:
        return
    _current_music = path
    if ResourceLoader.exists(path):
        _music_player.stream = load(path)
        _music_player.volume_db = linear_to_db(music_volume)
        _music_player.play()


func stop_music():
    _music_player.stop()
    _current_music = ""


func play_sfx(path: String):
    if not ResourceLoader.exists(path):
        return
    var stream = load(path)
    for p in _sfx_players:
        if not p.playing:
            p.stream = stream
            p.volume_db = linear_to_db(sfx_volume)
            p.play()
            return

    var extra = AudioStreamPlayer2D.new()
    extra.stream = stream
    extra.volume_db = linear_to_db(sfx_volume)
    add_child(extra)
    extra.finished.connect(extra.queue_free)
    extra.play()
    _sfx_players.append(extra)
    if _sfx_players.size() > 8:
        _sfx_players.pop_front()


func set_music_volume(value: float):
    music_volume = value


func set_sfx_volume(value: float):
    sfx_volume = value


func _update_music_volume():
    _music_player.volume_db = linear_to_db(music_volume)


func _update_sfx_volume():
    for p in _sfx_players:
        if p.playing:
            p.volume_db = linear_to_db(sfx_volume)


static func linear_to_db(value: float) -> float:
    if value <= 0.0:
        return -80.0
    return 20.0 * log(value) / log(10.0)
