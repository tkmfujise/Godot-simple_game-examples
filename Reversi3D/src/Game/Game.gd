extends Node3D

const MAX_LOCATION_NUMBER = 8
@onready var DiskScene = preload("res://src/Disk/Disk.tscn")
var current_color : Disk.COLOR


func _ready() -> void:
    initialize()


func initialize() -> void:
    clear_disks()
    put(Vector2(4, 4), Disk.COLOR.WHITE)
    put(Vector2(4, 5), Disk.COLOR.BLACK)
    put(Vector2(5, 4), Disk.COLOR.BLACK)
    put(Vector2(5, 5), Disk.COLOR.WHITE)
    current_color = Disk.COLOR.WHITE


func put(location: Vector2i, color: Disk.COLOR) -> void:
    var disk = DiskScene.instantiate()
    disk.location = location
    disk.color    = color
    $Board.add_disk(disk)


func clear_disks() -> void:
    $Board.clear_disks()


func get_disks() -> Array[Disk]:
    return $Board.get_disks()


func invalid_place(location: Vector2i, color: Disk.COLOR) -> bool:
    return out_of_range(location)


func out_of_range(location: Vector2i) -> bool:
    return not (
        (1 <= location.x and location.x <= MAX_LOCATION_NUMBER) &&
        (1 <= location.y and location.y <= MAX_LOCATION_NUMBER)
    )


func _on_board_clicked(location: Vector2i) -> void:
    if !invalid_place(location, current_color):
        put(location, current_color)
