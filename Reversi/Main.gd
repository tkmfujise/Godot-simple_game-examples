extends Control

@onready var GameScene = $Container/GameContainer/Game


func get_player_info(_color: Disk.COLOR) -> Node:
    return $Container/InformationBar.get_children().filter(
        func(c): return c.disk_color == _color)[0]


func _on_new_button_pressed() -> void:
    GameScene.initialize(Disk.COLOR.BLACK)


func _on_game_color_count_changed(white_count: int, black_count: int) -> void:
    get_player_info(Disk.COLOR.WHITE).disk_count = white_count
    get_player_info(Disk.COLOR.BLACK).disk_count = black_count


func _on_game_turn_changed() -> void:
    get_player_info(Disk.COLOR.WHITE).selected = false
    get_player_info(Disk.COLOR.BLACK).selected = false
    get_player_info(GameScene.current_color).selected = true
