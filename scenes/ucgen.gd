extends Area2D

@export var sutun: int = 0

func _ready():
	input_event.connect(_on_ucgen_input_event)

func _on_ucgen_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventScreenTouch and event.pressed:
		_atesle()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_atesle()

func _atesle():
	owner.get_node("KucukSandikOlustur").firlat(sutun)
