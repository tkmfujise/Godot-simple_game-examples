extends Polygon2D

signal clicked(location: Vector2i)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton && event.is_pressed():
        print("Mouse event got: ", get_local_mouse_position())
        var location = calc_location(get_local_mouse_position())
        emit_signal("clicked", location)


func calc_location(postion: Vector2) -> Vector2i:
    return (postion / Settings.TILE_SIZE).ceil()
