extends Node

var current_level_id: String = ""
var levels: Dictionary = {}

signal level_started(level_id: String)
signal level_completed(success: bool)


func load_level(level_id: String):
    current_level_id = level_id
    level_started.emit(level_id)


func complete_level(success: bool):
    level_completed.emit(success)
