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
    return moves
