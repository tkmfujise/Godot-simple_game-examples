extends Node

class_name CPU

var color : Disk.COLOR
var game : Game

class Move:
    var location : Vector2i
    var reversible_count : int


func initialize(_game: Game) -> void:
    game = _game
    if _game.player_color == Disk.COLOR.BLACK:
        color = Disk.COLOR.WHITE
    else: color = Disk.COLOR.BLACK


func perform() -> void:
    var location = decide_place()
    game.place(location)


func decide_place() -> Vector2i:
    var location = placeable_moves().pick_random().location
    print("decide_location: ", location)
    return location


func placeable_moves() -> Array:
    var moves = []
    for x in range(1, Game.MAX_LOCATION_NUMBER + 1):
        for y in range(1, Game.MAX_LOCATION_NUMBER + 1):
            var location = Vector2i(x, y)
            if game.invalid_place(location, color): continue
            var count = game.reversible_count(location, color)
            if count:
                var move = Move.new()
                move.location = location
                move.reversible_count = count
                moves.append(move)
    moves.shuffle()
    return moves


func sort_benefit_move(a: Move, b: Move) -> bool:
    return benefit_order(a) < benefit_order(b)


func benefit_order(move: Move) -> Array:
    var primary = 1 if is_corner(move.location) else 0
    return [primary, move.reversible_count]


func is_corner(location: Vector2i) -> bool:
    return location == Vector2i(1, 1) \
        or location == Vector2i(8, 1) \
        or location == Vector2i(1, 8) \
        or location == Vector2i(8, 8)
