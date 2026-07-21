extends Node

var initialized: bool = false
var player_lang: String = "ru"


func _ready():
    if OS.has_feature("web"):
        _init_sdk()


func _init_sdk():
    pass


func loading_api_ready():
    pass
