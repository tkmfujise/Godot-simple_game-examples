extends CPU

class_name HardCPU


func decide_place() -> Vector2i:
    var moves = placeable_moves()
    moves.sort_custom(sort_benefit_move)
    return moves[-1].location
