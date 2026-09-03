extends Node2D

const SeviyeVeritabani = preload("res://scripts/seviye_veritabani.gd")
const DilYoneticisi = preload("res://scripts/dil_yoneticisi.gd")

@onready var hakkimizda_paneli: Panel = $HakkimizdaPaneli
@onready var hakkimizda_karartma: ColorRect = $HakkimizdaKarartma
@onready var hakkimizda_ekrani: Panel = $HakkimizdaEkrani
var arkaplan: TextureRect
var ilerleme_paneli: Panel
var ilerleme_baslik: Label
var ilerleme_metin: Label
var gizlilik_paneli: Panel
var gizlilik_metin: Label
var gizlilik_baglanti_dugmesi: Button
var gizlilik_veri_dugmesi: Button
var gizlilik_silme_onayi := false
var tema_mesaji := ""
var dil_dugmeleri: Dictionary = {}

func _ready():
	_arkaplani_kur()
	_baslangic_logosunu_kur()
	_ilerleme_panelini_kur()
	_gizlilik_panelini_kur()
	_dil_sekmelerini_kur()
	Global.dil_degisti.connect(_on_dil_degisti)
	_metinleri_yenile()

func _t(anahtar: String, degerler: Dictionary = {}) -> String:
	return Global.cevir(anahtar, degerler)

func _dil_sekmelerini_kur():
	var satir = HBoxContainer.new()
	satir.name = "DilSekmeleri"
	satir.position = Vector2(76, 268)
	satir.size = Vector2(424, 30)
	satir.alignment = BoxContainer.ALIGNMENT_CENTER
	satir.add_theme_constant_override("separation", 4)
	$MenuButonlar/UI.add_child(satir)
	for dil in DilYoneticisi.DILLER:
		var dugme = Button.new()
		var kod := str(dil["kod"])
		dugme.custom_minimum_size = Vector2(72 if kod != "ar" else 160, 30)
		dugme.text = str(dil["etiket"])
		dugme.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
		dugme.add_theme_font_size_override("font_size", 17)
		dugme.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
		dugme.flat = true
		dugme.pressed.connect(func(): Global.dili_ayarla(kod))
		satir.add_child(dugme)
		dil_dugmeleri[kod] = dugme

func _metinleri_yenile():
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Basla.text = _t("play")
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Ayarlar.text = _t("progress")
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Açıklama.text = _t("how_to_play")
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Hakkımızda.text = _t("about")
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Gizlilik.text = _t("privacy")
	$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Çıkış.text = _t("exit")
	$MenuButonlar/ZorMenuButonlar/ZorMenu/Kolay.text = _t("easy")
	$MenuButonlar/ZorMenuButonlar/ZorMenu/Orta.text = _t("medium")
	$MenuButonlar/ZorMenuButonlar/ZorMenu/Zor.text = _t("hard")
	$MenuButonlar/ZorMenuButonlar/ZorMenu/Geri.text = _t("back")
	$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/Sandik.text = _t("game_mode_chest")
	$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/SandikRenk.text = _t("game_mode_chest_colors")
	$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/UcgenRenk.text = _t("game_mode_triangle_colors")
	$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/Geri.text = _t("back")
	for menu_yolu in [
		"MenuButonlar/SandikRenkMenuButonlar/SandikRenkMenu",
		"MenuButonlar/UcgenRenkMenuButonlar/UcgenRenkMenu",
	]:
		var menu = get_node(menu_yolu)
		menu.get_node("Kolay").text = _t("easy")
		menu.get_node("Orta").text = _t("medium")
		menu.get_node("Zor").text = _t("hard")
		menu.get_node("Geri").text = _t("back")
	$MenuButonlar/Sayac/GeriButon.text = _t("back")
	$MenuButonlar/TekrarDene/TekrarLabel.text = _t("try_again")
	$HakkimizdaPaneli/Baslik.text = _t("how_title")
	$HakkimizdaPaneli/Metin.text = _t("how_body")
	$HakkimizdaPaneli/Kapat.text = _t("close")
	$HakkimizdaEkrani/Baslik.text = _t("about_title")
	$HakkimizdaEkrani/Metin.text = _t("about_body")
	$HakkimizdaEkrani/Geri.text = _t("back")
	_ana_menu_yazilarini_uygula()
	for kod in dil_dugmeleri:
		dil_dugmeleri[kod].disabled = kod == Global.dil_kodu()
	_etiket_yonunu_uygula($HakkimizdaPaneli/Metin)
	_etiket_yonunu_uygula($HakkimizdaEkrani/Metin)
	_gizlilik_metinlerini_yenile()
	if ilerleme_paneli and ilerleme_paneli.visible:
		_ilerleme_ozetini_goster()

func _etiket_yonunu_uygula(etiket: Label):
	var rtl := Global.rtl_mi()
	etiket.text_direction = Control.TEXT_DIRECTION_RTL if rtl else Control.TEXT_DIRECTION_LTR
	etiket.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if rtl else HORIZONTAL_ALIGNMENT_CENTER

func _ana_menu_yazilarini_uygula():
	# Arapça sistem yazı tipi, mevcut başlık yazı tipinden belirgin biçimde daha yüksek
	# çizilir. Bu yüzden yalnızca RTL menüleri küçültüp tüm satırları görünür tutuyoruz.
	var rtl := Global.rtl_mi()
	var boyut := 40 if rtl else 60
	var menuler: Array[Button] = [
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Basla,
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Ayarlar,
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Açıklama,
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Hakkımızda,
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Gizlilik,
		$MenuButonlar/BaslaMenuButonlar/BaslaMenu/Çıkış,
		$MenuButonlar/ZorMenuButonlar/ZorMenu/Kolay,
		$MenuButonlar/ZorMenuButonlar/ZorMenu/Orta,
		$MenuButonlar/ZorMenuButonlar/ZorMenu/Zor,
		$MenuButonlar/ZorMenuButonlar/ZorMenu/Geri,
		$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/Sandik,
		$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/SandikRenk,
		$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/UcgenRenk,
		$MenuButonlar/OyunTurMenuButonlar/OyunTurMenu/Geri,
		$MenuButonlar/SandikRenkMenuButonlar/SandikRenkMenu/Kolay,
		$MenuButonlar/SandikRenkMenuButonlar/SandikRenkMenu/Orta,
		$MenuButonlar/SandikRenkMenuButonlar/SandikRenkMenu/Zor,
		$MenuButonlar/SandikRenkMenuButonlar/SandikRenkMenu/Geri,
		$MenuButonlar/UcgenRenkMenuButonlar/UcgenRenkMenu/Kolay,
		$MenuButonlar/UcgenRenkMenuButonlar/UcgenRenkMenu/Orta,
		$MenuButonlar/UcgenRenkMenuButonlar/UcgenRenkMenu/Zor,
		$MenuButonlar/UcgenRenkMenuButonlar/UcgenRenkMenu/Geri,
		$MenuButonlar/Sayac/GeriButon,
		$MenuButonlar/TekrarDene/TekrarLabel,
	]
	for dugme in menuler:
		dugme.add_theme_font_size_override("font_size", boyut)
		dugme.text_direction = Control.TEXT_DIRECTION_RTL if rtl else Control.TEXT_DIRECTION_LTR
		dugme.alignment = HORIZONTAL_ALIGNMENT_CENTER

func _on_dil_degisti(_kod: String):
	_metinleri_yenile()

func _arkaplani_kur():
	arkaplan = TextureRect.new()
	arkaplan.position = Vector2.ZERO
	arkaplan.size = get_viewport().get_visible_rect().size
	arkaplan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arkaplan_temasini_uygula()
	add_child(arkaplan)
	move_child(arkaplan, 0)

func _arkaplan_temasini_uygula():
	if arkaplan == null:
		return
	var tema = Global.secili_tema()
	var gradyan = Gradient.new()
	gradyan.set_color(0, tema["ust"])
	gradyan.set_color(1, tema["alt"])
	var doku = GradientTexture2D.new()
	doku.gradient = gradyan
	doku.fill_from = Vector2(0.5, 0)
	doku.fill_to = Vector2(0.5, 1)
	arkaplan.texture = doku

func _baslangic_logosunu_kur():
	var logo = TextureRect.new()
	logo.name = "BaslangicLogo"
	logo.position = Vector2(223, 28)
	logo.size = Vector2(130, 130)
	logo.texture = preload("res://logo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.pivot_offset = logo.size / 2.0
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.55, 0.55)
	$MenuButonlar/UI.add_child(logo)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo, "modulate:a", 1.0, 0.35)
	tween.parallel().tween_property(logo, "scale", Vector2.ONE, 0.45)
	tween.tween_property(logo, "scale", Vector2(1.06, 1.06), 0.12)
	tween.tween_property(logo, "scale", Vector2.ONE, 0.12)

func _ilerleme_panelini_kur():
	ilerleme_paneli = Panel.new()
	ilerleme_paneli.name = "IlerlemePaneli"
	ilerleme_paneli.position = Vector2(22, 95)
	ilerleme_paneli.size = Vector2(532, 650)
	ilerleme_paneli.z_index = 30
	var stil = StyleBoxFlat.new()
	stil.bg_color = Color("#182442")
	stil.corner_radius_top_left = 18
	stil.corner_radius_top_right = 18
	stil.corner_radius_bottom_left = 18
	stil.corner_radius_bottom_right = 18
	stil.border_width_left = 2
	stil.border_width_top = 2
	stil.border_width_right = 2
	stil.border_width_bottom = 2
	stil.border_color = Color(0.84, 0.84, 0.83, 0.55)
	ilerleme_paneli.add_theme_stylebox_override("panel", stil)
	add_child(ilerleme_paneli)
	ilerleme_baslik = _panel_etiketi(Vector2(22, 18), Vector2(488, 54), 38)
	ilerleme_baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ilerleme_paneli.add_child(ilerleme_baslik)
	ilerleme_metin = _panel_etiketi(Vector2(28, 82), Vector2(476, 250), 21)
	ilerleme_metin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ilerleme_paneli.add_child(ilerleme_metin)
	_panel_dugmesi("SeviyeBaslat", "", 342, _on_seviye_baslat_pressed)
	_panel_dugmesi("Basarimlar", "", 394, _on_basarimlar_pressed)
	_panel_dugmesi("Gunluk", "", 446, _on_gunluk_pressed)
	_panel_dugmesi("Kozmetik", "", 498, _on_kozmetik_pressed)
	_panel_dugmesi("Titresim", "", 550, _on_titresim_pressed)
	_panel_dugmesi("Kapat", "", 594, _on_ilerleme_kapat_pressed, 30)
	ilerleme_paneli.hide()

func _panel_etiketi(konum: Vector2, boyut: Vector2, yazi_boyutu: int) -> Label:
	var etiket = Label.new()
	etiket.position = konum
	etiket.size = boyut
	etiket.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	etiket.add_theme_font_size_override("font_size", yazi_boyutu)
	etiket.add_theme_color_override("font_color", Color(0.93, 0.93, 0.9, 1))
	return etiket

func _panel_dugmesi(ad: String, metin: String, y: float, baglanti: Callable, yazi_boyutu := 25):
	var dugme = Button.new()
	dugme.name = ad
	dugme.position = Vector2(70, y)
	dugme.size = Vector2(392, 42)
	dugme.text = metin
	dugme.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	dugme.add_theme_font_size_override("font_size", yazi_boyutu)
	dugme.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	dugme.flat = true
	dugme.pressed.connect(baglanti)
	ilerleme_paneli.add_child(dugme)

func _on_ilerleme_pressed():
	tema_mesaji = ""
	ilerleme_paneli.show()
	_ilerleme_ozetini_goster()

func _ilerleme_ozetini_goster():
	ilerleme_baslik.text = _t("progress_center")
	ilerleme_metin.text = _t("progress_summary", {"next": Global.sonraki_acik_seviye(), "total": SeviyeVeritabani.TOPLAM_SEVIYE, "completed": Global.ilerleme["tamamlanan_seviyeler"].size(), "score": Global.rekor, "streak": Global.ilerleme["en_yuksek_seri"], "stars": Global.ilerleme["kozmetik_para"], "message": tema_mesaji})
	var panel_metinleri := {"SeviyeBaslat": "start_next", "Basarimlar": "achievements", "Gunluk": "daily_tasks", "Kozmetik": "cosmetic_theme", "Titresim": "vibration", "Kapat": "close"}
	for dugme_adi in panel_metinleri:
		ilerleme_paneli.get_node(dugme_adi).text = _t(panel_metinleri[dugme_adi])
	_etiket_yonunu_uygula(ilerleme_metin)

func _on_seviye_baslat_pressed():
	$KucukSandikOlustur.baslat_seviye(Global.sonraki_acik_seviye())
	ilerleme_paneli.hide()

func _on_basarimlar_pressed():
	ilerleme_baslik.text = _t("achievements")
	var satirlar: Array[String] = []
	for basarim in Global.BASARIMLAR:
		var acik = Global.ilerleme["basarimlar"].get(basarim["id"], false)
		satirlar.append(("✓ " if acik else "🔒 ") + Global.basarim_adi(basarim) + " — " + Global.basarim_aciklamasi(basarim))
	ilerleme_metin.text = "\n".join(satirlar)

func _on_gunluk_pressed():
	ilerleme_baslik.text = _t("daily_tasks")
	var satirlar: Array[String] = []
	for gorev in Global.ilerleme["gunluk"]["gorevler"]:
		var durum = "✓" if gorev["tamamlandi"] else "%d/%d" % [gorev["ilerleme"], gorev["hedef"]]
		satirlar.append("%s  %s  (+%d ★)" % [durum, Global.gunluk_gorev_metni(gorev), gorev["odul"]])
	ilerleme_metin.text = _t("today") + "\n\n" + "\n".join(satirlar) + "\n\n" + _t("daily_note")

func _on_kozmetik_pressed():
	var temalar = Global.temalari_al()
	var secili_id = Global.secili_tema()["id"]
	var sonraki = temalar[0]
	for i in range(temalar.size()):
		if temalar[i]["id"] == secili_id:
			sonraki = temalar[(i + 1) % temalar.size()]
			break
	if Global.tema_al_veya_sec(sonraki["id"]):
		tema_mesaji = _t("theme_selected", {"theme": Global.tema_adi(sonraki)})
		_arkaplan_temasini_uygula()
	else:
		tema_mesaji = _t("theme_cost", {"theme": Global.tema_adi(sonraki), "price": sonraki["fiyat"]})
	_ilerleme_ozetini_goster()

func _on_titresim_pressed():
	var acik = Global.titresimi_degistir()
	tema_mesaji = _t("vibration_on" if acik else "vibration_off")
	_ilerleme_ozetini_goster()

func _on_ilerleme_kapat_pressed():
	ilerleme_paneli.hide()

func _gizlilik_panelini_kur():
	gizlilik_paneli = Panel.new()
	gizlilik_paneli.name = "GizlilikPaneli"
	gizlilik_paneli.position = Vector2(22, 70)
	gizlilik_paneli.size = Vector2(532, 670)
	gizlilik_paneli.z_index = 30
	var stil = StyleBoxFlat.new()
	stil.bg_color = Color("#182442")
	stil.corner_radius_top_left = 18
	stil.corner_radius_top_right = 18
	stil.corner_radius_bottom_left = 18
	stil.corner_radius_bottom_right = 18
	stil.border_width_left = 2
	stil.border_width_top = 2
	stil.border_width_right = 2
	stil.border_width_bottom = 2
	stil.border_color = Color(0.84, 0.84, 0.83, 0.55)
	gizlilik_paneli.add_theme_stylebox_override("panel", stil)
	add_child(gizlilik_paneli)
	var baslik = _panel_etiketi(Vector2(22, 16), Vector2(488, 46), 34)
	baslik.name = "Baslik"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gizlilik_paneli.add_child(baslik)
	gizlilik_metin = _panel_etiketi(Vector2(30, 74), Vector2(472, 404), 17)
	gizlilik_metin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gizlilik_paneli.add_child(gizlilik_metin)
	gizlilik_baglanti_dugmesi = Button.new()
	gizlilik_baglanti_dugmesi.name = "PolitikaBaglantisi"
	gizlilik_baglanti_dugmesi.position = Vector2(58, 480)
	gizlilik_baglanti_dugmesi.size = Vector2(416, 40)
	gizlilik_baglanti_dugmesi.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	gizlilik_baglanti_dugmesi.add_theme_font_size_override("font_size", 22)
	gizlilik_baglanti_dugmesi.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	gizlilik_baglanti_dugmesi.flat = true
	gizlilik_baglanti_dugmesi.pressed.connect(_on_gizlilik_baglanti_pressed)
	gizlilik_paneli.add_child(gizlilik_baglanti_dugmesi)
	gizlilik_veri_dugmesi = Button.new()
	gizlilik_veri_dugmesi.name = "VeriSifirla"
	gizlilik_veri_dugmesi.position = Vector2(58, 528)
	gizlilik_veri_dugmesi.size = Vector2(416, 46)
	gizlilik_veri_dugmesi.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	gizlilik_veri_dugmesi.add_theme_font_size_override("font_size", 24)
	gizlilik_veri_dugmesi.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	gizlilik_veri_dugmesi.flat = true
	gizlilik_veri_dugmesi.pressed.connect(_on_gizlilik_veri_sifirla_pressed)
	gizlilik_paneli.add_child(gizlilik_veri_dugmesi)
	var kapat = Button.new()
	kapat.name = "Kapat"
	kapat.position = Vector2(170, 582)
	kapat.size = Vector2(192, 48)
	kapat.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	kapat.add_theme_font_size_override("font_size", 28)
	kapat.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	kapat.flat = true
	kapat.pressed.connect(_on_gizlilik_kapat_pressed)
	gizlilik_paneli.add_child(kapat)
	_gizlilik_metinlerini_yenile()
	gizlilik_paneli.hide()

func _gizlilik_metinlerini_yenile():
	if gizlilik_paneli == null:
		return
	gizlilik_paneli.get_node("Baslik").text = _t("privacy_title")
	gizlilik_metin.text = _t("privacy_body")
	_etiket_yonunu_uygula(gizlilik_metin)
	gizlilik_baglanti_dugmesi.text = _t("open_policy")
	if not gizlilik_silme_onayi:
		gizlilik_veri_dugmesi.text = _t("reset_data")
	gizlilik_paneli.get_node("Kapat").text = _t("close")

func _on_gizlilik_pressed():
	gizlilik_silme_onayi = false
	gizlilik_veri_dugmesi.text = _t("reset_data")
	gizlilik_paneli.show()

func _on_gizlilik_baglanti_pressed():
	OS.shell_open("https://ttaskesen.github.io/SandikDustu/PRIVACY_POLICY.html")

func _on_gizlilik_veri_sifirla_pressed():
	if not gizlilik_silme_onayi:
		gizlilik_silme_onayi = true
		gizlilik_veri_dugmesi.text = _t("reset_confirm")
		return
	if Global.yerel_verileri_sifirla():
		gizlilik_silme_onayi = false
		gizlilik_veri_dugmesi.text = _t("data_reset")
	else:
		gizlilik_silme_onayi = false
		gizlilik_veri_dugmesi.text = _t("reset_failed")

func _on_gizlilik_kapat_pressed():
	gizlilik_paneli.hide()

func _on_çıkış_pressed():
	get_tree().quit()

func _on_aciklama_pressed():
	hakkimizda_karartma.show()
	hakkimizda_paneli.show()

func _on_aciklama_kapat_pressed():
	hakkimizda_paneli.hide()
	hakkimizda_karartma.hide()

func _on_hakkimizda_pressed():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(hakkimizda_ekrani, "position", Vector2.ZERO, 0.6)

func _on_hakkimizda_geri_pressed():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(hakkimizda_ekrani, "position", Vector2(576, 0), 0.6)
