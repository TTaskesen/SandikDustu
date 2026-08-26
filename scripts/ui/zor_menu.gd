extends VBoxContainer

func _on_geri_pressed():
	var yonetici = owner.get_node("KucukSandikOlustur")
	yonetici.oyunu_sifirla()
	yonetici.ekrani_ac()

func _on_geri_buton_pressed():
	var yonetici = owner.get_node("KucukSandikOlustur")
	yonetici.oyunu_sifirla()
	yonetici.ekrani_ac()

func _on_tekrar_label_pressed():
	owner.get_node("KucukSandikOlustur").tekrar_oyna()
