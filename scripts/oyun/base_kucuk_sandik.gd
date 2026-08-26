extends Area2D
class_name ParentKucuk

@export var speed: int = 100
@export var renk: String = ""

var firlatildi = false

func _process(delta):
	position.y += speed * delta
