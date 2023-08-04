extends Node3D

class_name Disk

enum COLOR { WHITE, BLACK }

@onready var mesh = $Mesh
@onready var animation = $Mesh/AnimationPlayer
@export var color : COLOR : set = change_color
@export var location : Vector2i


func _ready() -> void:
    set_mesh_rotation()


func change_color(_color: COLOR) -> void:
    color = _color
    set_mesh_rotation()


func set_mesh_rotation() -> void:
    if !animation: return
    if color == COLOR.WHITE:
        animation.set("current_animation", "WhiteToBlack")
    else:
        animation.set("current_animation", "BlackToWhite")
    animation.stop()


func reverse() -> void:
    animation.play()


func _on_animation_finished(anim_name: StringName) -> void:
    if color == COLOR.WHITE:
        color = COLOR.BLACK
    else:
        color = COLOR.WHITE
