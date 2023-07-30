extends CPU

class_name HardCPU


func sort_reversible_count(a: Move, b: Move) -> bool:
    return a.reversible_count < b.reversible_count


func decide_place() -> Vector2i:
    var moves = placeable_moves()
    moves.sort_custom(sort_reversible_count)
    return moves[-1].location
