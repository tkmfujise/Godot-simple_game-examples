extends PanelContainer

const WhiteImage = preload("res://assets/Disk_white.png")
const BlackImage = preload("res://assets/Disk_black.png")
const SELECTED_BG_COLOR = Color("#fffa63")

@export var player_name : String : set = set_player_name
@export var disk_color : Disk.COLOR : set = set_disk_color
@export var disk_count : int : set = change_disk_count
@export var selected : bool : set = change_selected
var default_bg_color : Color

func _ready() -> void:
    default_bg_color = self_modulate


func setup(_name: String, _color: Disk.COLOR, _count: int) -> void:
    player_name = _name
    disk_color  = _color
    disk_count  = _count


func set_player_name(_name: String) -> void:
    $Container/Name.text = _name
    player_name = _name


func set_disk_color(_color: Disk.COLOR) -> void:
    var image = WhiteImage if _color == Disk.COLOR.WHITE else BlackImage
    $Container/Disk/Color/Image.texture = image
    disk_color = _color


func change_disk_count(_count: int) -> void:
    $Container/Disk/Count.text = str(_count)
    disk_count = _count


func change_selected(_bool: bool) -> void:
    self_modulate = SELECTED_BG_COLOR if _bool else default_bg_color
