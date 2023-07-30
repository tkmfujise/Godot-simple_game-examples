extends AnimatedSprite2D

class_name Disk

enum COLOR { WHITE, BLACK }

@export var color : COLOR : set = change_color
@export var location = Vector2i(1, 1) : set = set_location


func set_location(_location: Vector2i) -> void:
    position = (_location - Vector2i(1, 1)) * Settings.TILE_SIZE
    location = _location


func change_color(_color: COLOR) -> void:
    color = _color
    if color == COLOR.WHITE:
        set_animation("white_to_black")
    else:
        set_animation("black_to_white")


func reverse() -> void:
    play()


func _on_animation_finished() -> void:
    if color == COLOR.WHITE:
        color = COLOR.BLACK
    else:
        color = COLOR.WHITE
