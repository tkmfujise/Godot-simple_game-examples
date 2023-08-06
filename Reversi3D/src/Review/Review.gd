extends Control

signal animation_finished

@onready var DiskScene = preload("res://src/Disk/Disk.tscn")

var black_disk_count : int = 20
var white_disk_count : int = 35

var next_black_locations : Array[Vector2i]
var next_white_locations : Array[Vector2i]

var high_speed := 0.05


func _ready() -> void:
    set_last_game_result()
    set_each_color_locations()
    set_each_color_score()


func set_last_game_result() -> void:
    if LastGameResult.black_disk_count + LastGameResult.white_disk_count:
        black_disk_count = LastGameResult.black_disk_count
        white_disk_count = LastGameResult.white_disk_count


func set_each_color_locations() -> void:
    var black_put_count = 0
    var gap_count = 64 - black_disk_count - white_disk_count
    for x in range(1, Game.MAX_LOCATION_NUMBER + 1):
        for y in range(1, Game.MAX_LOCATION_NUMBER + 1):
            if black_put_count < black_disk_count:
                next_black_locations.append(Vector2i(x, y))
                black_put_count += 1
            elif gap_count: gap_count -= 1
            else: next_white_locations.append(Vector2i(x, y))


# TODO プレイヤーが黒とは限らない
func set_each_color_score() -> void:
    $Score.visible = false
    $Score/Player/Count.text = str(black_disk_count)
    $Score/CPU/Count.text    = str(white_disk_count)


func put(location: Vector2i, color: Disk.COLOR) -> Disk:
    var disk = DiskScene.instantiate()
    disk.location = location
    disk.color    = color
    add_disk(disk)
    return disk


func add_disk(disk: Disk) -> void:
    disk.position.y = Board.DISK_Y_OFFSET
    disk.position.x = Board.TILE_OFFSET * (disk.location.x - 1)
    disk.position.z = Board.TILE_OFFSET * (disk.location.y - 1)
    $Board.add_child(disk)


func _on_timer_timeout() -> void:
    if next_black_locations or next_white_locations:
        if next_black_locations:
            var location = next_black_locations.pop_front()
            put(location, Disk.COLOR.BLACK)
        if next_white_locations:
            var location = next_white_locations.pop_back()
            put(location, Disk.COLOR.WHITE)
        if !next_black_locations or !next_white_locations:
            $Timer.wait_time = high_speed
    else:
        $Timer.stop()
        emit_signal("animation_finished")


func _on_animation_finished() -> void:
    $Score.visible = true


func _on_new_game_button_pressed() -> void:
    get_tree().change_scene_to_file("res://src/Main.tscn")
