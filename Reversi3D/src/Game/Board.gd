extends Node3D

signal clicked

const DISK_Y_OFFSET = 0.017
const TILE_OFFSET   = 0.045


func add_disk(disk: Disk) -> void:
    disk.position.y = DISK_Y_OFFSET
    disk.position.x = TILE_OFFSET * (disk.location.x - 1)
    disk.position.z = TILE_OFFSET * (disk.location.y - 1)
    $Disks.add_child(disk)


func clear_disks() -> void:
    for disk in get_disks(): disk.queue_free()


func get_disks() -> Array[Node]:
    return $Disks.get_children()


# レイキャストで当たったポジションを8等分して座標を取得
func calc_location(_position: Vector2) -> Vector2i:
    var camera     = get_tree().root.get_camera_3d()
    var worldspace = get_world_3d().direct_space_state
    var ray_origin = camera.project_ray_origin(_position)
    var ray_end    = camera.project_position(_position, 1000)
    var query  = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    var result = worldspace.intersect_ray(query)
    if !result.has('position'): return Vector2i.ZERO
    var shape_size   = $StaticBody/CollisionShape.shape.size
    var offset       = $StaticBody/CollisionShape.position
    var end_position = ((result['position'] + offset) / shape_size * 0.8).ceil()
    print("result: ", result['position'] , ", end_position: ", end_position)
    return Vector2i(end_position.x, end_position.z)


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton && event.is_pressed():
        print("Mouse event got: ", event.position)
        var _position = get_viewport().get_mouse_position()
        var location = calc_location(_position)
        if location != Vector2i.ZERO:
            print(location)
            emit_signal("clicked", location)
