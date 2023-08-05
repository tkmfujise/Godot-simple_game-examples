extends Control


func new_game(player_color: Disk.COLOR, cpu_level: Object) -> void:
    $Game.initialize(player_color, cpu_level)


func _on_new_game_button_pressed() -> void:
    new_game(Disk.COLOR.BLACK, EasyCPU)
