extends Node2D

func _on_kolay_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(1.5, 200, "kolay")
