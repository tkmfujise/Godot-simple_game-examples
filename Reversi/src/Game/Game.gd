extends Control

class_name Game

signal color_count_changed
signal turn_changed
signal all_animation_finished

const DiskScene = preload("res://src/Disk/Disk.tscn")
const MAX_LOCATION_NUMBER = 8

var current_color : Disk.COLOR = Disk.COLOR.BLACK
var player_color : Disk.COLOR
var animation_disks : Array[Node] = []
var cpu : CPU


func _ready() -> void:
    initialize(Disk.COLOR.BLACK)


func initialize(_player_color: Disk.COLOR) -> void:
    clear_disks()
    put(Vector2i(4, 4), Disk.COLOR.WHITE)
    put(Vector2i(4, 5), Disk.COLOR.BLACK)
    put(Vector2i(5, 4), Disk.COLOR.BLACK)
    put(Vector2i(5, 5), Disk.COLOR.WHITE)
    print(get_disks().map(func(d): return d.location))
    emit_signal_color_count_changed()
    player_color  = _player_color
    current_color = Disk.COLOR.BLACK
    # setup_cpu(EasyCPU)
    setup_cpu(NormalCPU)
    # setup_cpu(HardCPU)


func setup_cpu(level: Object) -> void:
    cpu = level.new()
    cpu.initialize(self)


func is_player_turn() -> bool:
    return current_color == player_color


# TODO 置ける場所が無い場合に"パス"をできるようにする
func place(location: Vector2i) -> void:
    if invalid_place(location, current_color):
        printerr("invalid place tried: ", location)
    else:
        var disk = put(location, current_color)
        try_reverse_by(disk)


func put(location: Vector2i, color: Disk.COLOR) -> Disk:
    var disk = DiskScene.instantiate()
    disk.location = location
    disk.color    = color
    disk.animation_finished.connect(_on_disk_animation_finished)
    $Board.add_child(disk)
    return disk


func clear_disks() -> void:
    for disk in get_disks(): $Board.remove_child(disk)


func get_disks() -> Array[Node]:
    return $Board.get_children()


func get_disk(location: Vector2i) -> Disk:
    var arr = get_disks().filter(
        func(d): return d.location == location)
    if arr.is_empty():
        return null
    else:
        return arr[0]


func get_color_count(color: Disk.COLOR) -> int:
    return get_disks().filter(func(d): return d.color == color).size()


func invalid_place(location: Vector2i, color: Disk.COLOR) -> bool:
    return already_placed(location) \
        or out_of_range(location) \
        or reversible_count(location, color) == 0


func already_placed(location: Vector2i) -> bool:
    return !!get_disk(location)


func out_of_range(location: Vector2i) -> bool:
    return not (
        (1 <= location.x and location.x <= MAX_LOCATION_NUMBER) &&
        (1 <= location.y and location.y <= MAX_LOCATION_NUMBER)
    )


func reversible_count(location: Vector2i, color: Disk.COLOR) -> int:
    var disk = DiskScene.instantiate()
    disk.location = location
    disk.color    = color
    return reversible_disks_by(disk).size()


func try_reverse_by(disk: Disk) -> void:
    for other in reversible_disks_by(disk):
        animation_disks.append(other)
        other.reverse()


func reversible_disks_by(disk: Disk) -> Array:
    var reversible_others = []
    for locations in directional_locations_from(disk.location):
        var line = []
        for next_location in locations:
            var next = get_disk(next_location)
            if next && next.color != disk.color:
                line.append(next)
            elif line && next && next.color == disk.color:
                line.append(next)
                break
            else: line = []; break
        if line.size() > 1 && line.pop_back().color == disk.color:
            reversible_others = reversible_others + line
    return reversible_others


# (5,5) => [
#   [(5,4), (5,3), (5,2), (5,1)],  # ↑
#   [(6,4), (7,3), (8,2)],         # ➚
#   [(4,4), (3,3), (2,2), (1,1)],  # ↖
#   [(6,5), (7,5), (8,5)],         # →
#   [(4,5), (3,5), (2,5), (1,5)],  # ←
#   [(6,6), (7,7), (8,8)],         # ➘
#   [(4,6), (3,7), (2,8)],         # ↙
#   [(5,6), (5,7), (5,8)],         # ↓
# ]
func directional_locations_from(base: Vector2i) -> Array[Array]:
    return [
        locations_line_from(base,  0, -1), # ↑
        locations_line_from(base,  1, -1), # ➚
        locations_line_from(base, -1, -1), # ↖
        locations_line_from(base,  1,  0), # →
        locations_line_from(base, -1,  0), # ←
        locations_line_from(base,  1,  1), # ➘
        locations_line_from(base, -1,  1), # ↙
        locations_line_from(base,  0,  1), # ↓
    ]


# locations_line_from(Vector2i(5, 5), -1, 1) => [(4, 6), (3, 7)...]
func locations_line_from(base: Vector2i, dx: int, dy: int) -> Array:
    var arr = []
    for i in range(1, MAX_LOCATION_NUMBER + 1):
        arr.append(Vector2i(base.x + (dx * i), base.y + (dy * i)))
    return arr.filter(func(v): return !out_of_range(v))


func take_turn() -> void:
    if current_color == Disk.COLOR.WHITE:
        current_color = Disk.COLOR.BLACK
    else:
        current_color = Disk.COLOR.WHITE
    emit_signal("turn_changed")
    if current_color == cpu.color: cpu.perform()


func emit_signal_color_count_changed() -> void:
    emit_signal("color_count_changed",
        get_color_count(Disk.COLOR.WHITE),
        get_color_count(Disk.COLOR.BLACK),
    )


func _on_board_clicked(location: Vector2i) -> void:
    print(location)
    if is_player_turn(): place(location)


func _on_disk_animation_finished() -> void:
    animation_disks = animation_disks.filter(
        func(c): return c.frame != 0)
    if animation_disks.is_empty():
        emit_signal("all_animation_finished")


func _on_all_animation_finished() -> void:
    emit_signal_color_count_changed()
    take_turn()
