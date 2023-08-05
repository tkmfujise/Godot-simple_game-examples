extends Path3D

signal finished

@export var text : String : set = set_text
@export_range (0, 1) var progress : float : set = set_progress

@onready var TextLabel = $PathFollow3D/Text
var callback : Callable


func _ready() -> void:
    visible = false
    # spawn(text)


func spawn(_text: String, _callback := Callable()) -> void:
    progress = 0
    text     = _text
    callback = _callback
    $Timer.start()


func set_text(_text: String) -> void:
    text = _text
    if !TextLabel: return
    TextLabel.text = text


func set_progress(_progress: float) -> void:
    progress = _progress
    if !$PathFollow3D: return
    $PathFollow3D.progress_ratio = _progress
    if 0.39 < progress && progress < 0.52:
        visible = true
    else:
        visible = false


func _on_timer_timeout() -> void:
    if 0.45 < progress && progress < 0.49:
        progress += 0.001
    elif 0.44 < progress && progress < 0.5:
        progress += 0.005
    elif 0.35 < progress && progress < 0.51:
        progress += 0.07
    elif progress > 1:
        progress = 0
        $Timer.stop()
        if callback: callback.call()
        emit_signal("finished")
    else:
        progress += 0.1

