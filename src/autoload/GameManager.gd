extends Node

var last_result: Dictionary = {}


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS


func go_to_scene(path: String):
    get_tree().change_scene_to_file(path)


func go_to_scene_with_data(path: String, data: Dictionary):
    last_result = data
    get_tree().change_scene_to_file(path)


func quit():
    get_tree().quit()
