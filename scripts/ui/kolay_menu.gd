extends Node2D

func _on_orta_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(2.0, 150, "orta")

func _on_zor_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(1.5, 100, "zor")

func _on_bariyer_area_entered(area):
	if area.get("firlatildi") == null or area.get("firlatildi"):
		return
	owner.get_node("KucukSandikOlustur").sandik_kacti()
