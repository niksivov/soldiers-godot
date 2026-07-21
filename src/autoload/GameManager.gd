extends Node


func _ready():
    pass


func go_to_scene(path: String):
    get_tree().change_scene_to_file(path)


func quit():
    get_tree().quit()
