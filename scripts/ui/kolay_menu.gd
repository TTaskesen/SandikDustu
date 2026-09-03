extends Node2D

func _on_orta_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(1.0, 250, "orta")

func _on_zor_pressed():
	owner.get_node("KucukSandikOlustur").oyunu_baslat(0.75, 300, "zor")

func _on_donen_kolay_pressed():
	owner.get_node("KucukSandikOlustur").donen_seviyeleri_baslat()

func _on_bariyer_area_entered(area):
	if area.get("firlatildi") == null or area.get("firlatildi"):
		return
	owner.get_node("KucukSandikOlustur").sandik_kacti()
