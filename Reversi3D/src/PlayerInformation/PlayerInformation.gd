extends PanelContainer

@export var player_name : String : set = set_player_name
@export var color : Disk.COLOR : set = set_color
@export var selected := false : set = change_selected

@onready var style = theme.get_stylebox("panel", "PanelContainer").duplicate()
var default_border_color : Color


func _ready() -> void:
    add_theme_stylebox_override("panel", style)
    default_border_color = style.get("border_color")
    set_style()


func set_player_name(_name: String) -> void:
    player_name = _name
    $Name.text  = _name


func set_color(_color: Disk.COLOR) -> void:
    color = _color
    set_style()


func change_selected(_selected: bool) -> void:
    selected = _selected
    set_style()


func set_style() -> void:
    if !style: return
    if color == Disk.COLOR.WHITE:
        style.set("bg_color", Color("#FFFFFF"))
        $Name.modulate = "#000000"
    else:
        style.set("bg_color", Color("#000000"))
        $Name.modulate = "#FFFFFF"

    if selected:
        style.set("border_color", Color("#FFFF00"))
    else:
        style.set("border_color", default_border_color)
