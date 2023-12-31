extends Node3D

class_name Game

signal turn_changed
signal passed
signal finished
signal ended

const MAX_LOCATION_NUMBER = 8
@onready var DiskScene = preload("res://src/Disk/Disk.tscn")

@export var player_as_cpu : bool
var current_color : Disk.COLOR
var player_color : Disk.COLOR
var cpu : CPU
var animation_disks : Array[Node] = []


func _ready() -> void:
    initialize(Disk.COLOR.BLACK, NormalCPU)
    if player_as_cpu: let_cpu_play()


func initialize(_player_color: Disk.COLOR, cpu_level: Object) -> void:
    clear_disks()
    animation_disks = []
    put(Vector2(4, 4), Disk.COLOR.WHITE)
    put(Vector2(4, 5), Disk.COLOR.BLACK)
    put(Vector2(5, 4), Disk.COLOR.BLACK)
    put(Vector2(5, 5), Disk.COLOR.WHITE)
    current_color = _player_color
    player_color  = current_color
    set_cpu(cpu_level)
    refresh_player_info()


func set_cpu(level: Object) -> void:
    cpu = level.new()
    cpu.initialize(self)


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
    $Board.add_disk(disk)
    return disk


func clear_disks() -> void:
    $Board.clear_disks()


func get_disks() -> Array[Node]:
    return $Board.get_disks()


func get_disk(location: Vector2i) -> Disk:
    var arr = get_disks().filter(
        func(d): return d.location == location)
    return arr[0] if arr else null


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


func placeable_locations(color: Disk.COLOR) -> Array:
    var locations = []
    for x in range(1, MAX_LOCATION_NUMBER + 1):
        for y in range(1, MAX_LOCATION_NUMBER + 1):
            var location = Vector2i(x, y)
            if !invalid_place(location, color):
                locations.append(location)
    return locations



func try_reverse_by(disk: Disk) -> void:
    for other in reversible_disks_by(disk):
        other.reverse()
        animation_disks.append(other)


func reversible_count(location: Vector2i, color: Disk.COLOR) -> int:
    var disk = DiskScene.instantiate()
    disk.location = location
    disk.color    = color
    return reversible_disks_by(disk).size()


func reversible_disks_by(disk: Disk) -> Array:
    var reversible_disks = []
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
            reversible_disks = reversible_disks + line
    return reversible_disks


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
    var opposite_color = current_color
    if current_color == Disk.COLOR.WHITE:
        current_color = Disk.COLOR.BLACK
    else:
        current_color = Disk.COLOR.WHITE
    emit_signal("turn_changed")

    if not placeable_locations(current_color):
        if placeable_locations(opposite_color):
            emit_signal("passed", current_color)
        else: emit_signal("finished")
    else:
        if current_color == cpu.color: cpu.perform()
        elif player_as_cpu: let_cpu_play()


func let_cpu_play() -> void:
    var pcpu = HardCPU.new()
    pcpu.initialize(self)
    pcpu.color = player_color
    pcpu.perform()
    pcpu.queue_free()


func refresh_player_info() -> void:
    for info in [$CPUInformation, $PlayerInformation]:
        info.selected = info.color == current_color


func _on_board_clicked(location: Vector2i) -> void:
    place(location)


func _on_disk_animation_finished(disk: Disk) -> void:
    animation_disks = animation_disks.filter(func(d): return d != disk)
    if animation_disks.is_empty(): take_turn()


func _on_turn_changed() -> void:
    refresh_player_info()


func _on_passed(_color: Disk.COLOR) -> void:
    $FlashMesage.spawn("Pass", take_turn)


func _on_finished() -> void:
    $FlashMesage.spawn("Game finished", func(): emit_signal("ended"))


