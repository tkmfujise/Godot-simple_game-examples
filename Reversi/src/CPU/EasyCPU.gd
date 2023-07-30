extends CPU

class_name EasyCPU


func sort_reversible_count(a: Move, b: Move) -> bool:
    return a.reversible_count < b.reversible_count


func decide_place() -> Vector2i:
    var moves = placeable_moves()
    moves.sort_custom(sort_reversible_count)
    return moves[0].location
