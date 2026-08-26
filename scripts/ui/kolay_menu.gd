extends Node2D

func _on_orta_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(2.0, 140, "orta")

func _on_zor_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(1.5, 190, "zor")

func _on_bariyer_area_entered(area):
	if area.get("firlatildi") == null or area.get("firlatildi"):
		return
	owner.get_node("KucukSandikOlustur").oyun_sonu()
