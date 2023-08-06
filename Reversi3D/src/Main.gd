extends Control

@export var ReviewScene : PackedScene


func new_game(player_color: Disk.COLOR, cpu_level: Object) -> void:
    $Game.initialize(player_color, cpu_level)


func store_game_result() -> void:
    LastGameResult.black_disk_count = $Game.get_color_count(Disk.COLOR.BLACK)
    LastGameResult.white_disk_count = $Game.get_color_count(Disk.COLOR.WHITE)


func _on_new_game_button_pressed() -> void:
    new_game(Disk.COLOR.BLACK, EasyCPU)


func _on_game_ended() -> void:
    store_game_result()
    get_tree().change_scene_to_packed(ReviewScene)

