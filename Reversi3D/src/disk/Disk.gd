extends Node3D

class_name Disk

enum COLOR { WHITE, BLACK }
const COLOR_ROTATION = {
    'white': Vector3(0, 0, 0),
    'black': Vector3(0, 0, -180),
}

@onready var mesh = $Mesh
@export var color : COLOR : set = change_color
@export var location : Vector2i


func _ready() -> void:
    set_mesh_rotation()


func change_color(_color: COLOR) -> void:
    color = _color
    set_mesh_rotation()


func set_mesh_rotation() -> void:
    if !mesh: return
    if color == COLOR.WHITE:
        mesh.rotation_degrees = Vector3(0, 0, 0)
    else:
        mesh.rotation_degrees = Vector3(180, 0, 0)

