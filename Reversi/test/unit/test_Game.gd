extends GutTest

class Test_initialize:
    extends GutTest

    var Game = load("res://src/Game/Game.tscn")
    var game = null

    func before_each():
        game = Game.instantiate()

    func test_disks():
        assert_eq(game.get_disks().size(), 4)
        assert_eq(
            game.get_disks().map(func(d): return [d.location, d.color]),
            [
            [Vector2i(4, 4), Disk.COLOR.WHITE],
            [Vector2i(4, 5), Disk.COLOR.BLACK],
            [Vector2i(5, 5), Disk.COLOR.WHITE],
            [Vector2i(5, 4), Disk.COLOR.BLACK],
            ]
        )
        game.place(Vector2i(3, 5))
        assert_eq(game.get_disks().size(), 5)
        game.initialize()
        assert_eq(game.get_disks().size(), 4)

    func test_current_color():
        assert_eq(game.current_color, Disk.COLOR.WHITE)
        game.take_turn()
        assert_eq(game.current_color, Disk.COLOR.BLACK)
        game.initialize()
        assert_eq(game.current_color, Disk.COLOR.WHITE)


class Test_place:
    extends GutTest

    var Game = load("res://src/Game/Game.tscn")
    var game = null

    func before_each():
        game = Game.instantiate()

    func test_valid():
        game.place(Vector2i(3, 5))
        assert_eq(game.get_disks().size(), 5)

    func test_invalid_as_out_of_range():
        game.place(Vector2i(0, 0))
        assert_eq(game.get_disks().size(), 4)

    func test_invalid_as_already_placed():
        game.place(Vector2i(4, 4))
        assert_eq(game.get_disks().size(), 4)

    func test_invalid_as_unreversible():
        game.place(Vector2i(1, 1))
        assert_eq(game.get_disks().size(), 4)


class Test_reversible_disks_by:
    extends GutTest

    var Game = load("res://src/Game/Game.tscn")
    var DiskScene = load("res://src/Disk/Disk.tscn")
    var game = null

    func before_each():
        game = Game.instantiate()
        game.clear_disks()

    func disk(x: int, y: int, color: Disk.COLOR) -> Disk:
        var disk = DiskScene.instantiate()
        disk.location = Vector2i(x, y)
        disk.color    = color
        return disk

    func sort_disk(a: Disk, b: Disk) -> bool:
        return a.location > b.location

    func reversible_test(subject: Array, expectation: Array) -> void:
        var subject_disk = disk(subject[0], subject[1], subject[2])
        var expectation_disks = []
        for arr in expectation:
            var e_disk = game.get_disk(Vector2i(arr[0], arr[1]))
            expectation_disks.append(e_disk)
        var result_disks = game.reversible_disks_by(subject_disk)
        for arr in [result_disks, expectation_disks]: arr.sort_custom(sort_disk)
        assert_eq(result_disks, expectation_disks)

    # | _ | ● | ◯ | _ |
    func test_case1():
        game.put(Vector2i(2, 1), Disk.COLOR.BLACK)
        game.put(Vector2i(3, 1), Disk.COLOR.WHITE)
        reversible_test([1, 1, Disk.COLOR.WHITE], [[2, 1]])
        reversible_test([1, 1, Disk.COLOR.BLACK], [])
        reversible_test([4, 1, Disk.COLOR.WHITE], [])
        reversible_test([4, 1, Disk.COLOR.BLACK], [[3, 1]])

    # | _ | ● | ◯ | ● | ◯ | _ |
    func test_case2():
        game.put(Vector2i(2, 1), Disk.COLOR.BLACK)
        game.put(Vector2i(3, 1), Disk.COLOR.WHITE)
        game.put(Vector2i(4, 1), Disk.COLOR.BLACK)
        game.put(Vector2i(5, 1), Disk.COLOR.WHITE)
        reversible_test([1, 1, Disk.COLOR.WHITE], [[2, 1]])
        reversible_test([1, 1, Disk.COLOR.BLACK], [])
        reversible_test([6, 1, Disk.COLOR.WHITE], [])
        reversible_test([6, 1, Disk.COLOR.BLACK], [[5, 1]])

    # | ◯ | ◯ | ◯ | ◯ | ◯ | ◯ | ◯ |
    # | ◯ | ● | ● | ● | ● | ● | ◯ |
    # | ◯ | ● | ● | ● | ● | ● | ◯ |
    # | ◯ | ● | ● | _ | ● | ● | ◯ |
    # | ◯ | ● | ● | ● | ● | ● | ◯ |
    # | ◯ | ● | ● | ● | ● | ● | ◯ |
    # | ◯ | ◯ | ◯ | ◯ | ◯ | ◯ | ◯ |
    func test_case3():
        for x in range(1, 8):
            for y in range(1, 8):
                if x == 1 or x == 7 or y == 1 or y == 7:
                    game.put(Vector2i(x, y), Disk.COLOR.WHITE)
                else:
                    game.put(Vector2i(x, y), Disk.COLOR.BLACK)
        reversible_test([4, 4, Disk.COLOR.BLACK], [])
        reversible_test([4, 4, Disk.COLOR.WHITE], [
            [2, 2],         [4, 2],         [6, 2],
                    [3, 3], [4, 3], [5, 3],
            [2, 4], [3, 4],         [5, 4], [6, 4],
                    [3, 5], [4, 5], [5, 5],
            [2, 6],         [4, 6],         [6, 6],
        ])
