extends CanvasModulate

const DAWN_COLOR = Color(0.7, 0.5, 0.5)
const DAY_COLOR = Color(1.0, 1.0, 1.0)
const DUSK_COLOR = Color(0.6, 0.4, 0.6)
const NIGHT_COLOR = Color(0.2, 0.2, 0.4)

func _ready() -> void:
    EventBus.time_changed.connect(_on_time_changed)
    _on_time_changed(GameState.time_of_day)

func _on_time_changed(time: float) -> void:
    var c: Color
    if time >= 5.0 and time < 8.0:
        c = NIGHT_COLOR.lerp(DAWN_COLOR, (time - 5.0) / 3.0)
    elif time >= 8.0 and time < 10.0:
        c = DAWN_COLOR.lerp(DAY_COLOR, (time - 8.0) / 2.0)
    elif time >= 10.0 and time < 17.0:
        c = DAY_COLOR
    elif time >= 17.0 and time < 19.0:
        c = DAY_COLOR.lerp(DUSK_COLOR, (time - 17.0) / 2.0)
    elif time >= 19.0 and time < 21.0:
        c = DUSK_COLOR.lerp(NIGHT_COLOR, (time - 19.0) / 2.0)
    else:
        c = NIGHT_COLOR
    color = c
