extends Node2D

const SeviyeVeritabani = preload("res://scripts/seviye_veritabani.gd")

@onready var hakkimizda_paneli: Panel = $HakkimizdaPaneli
@onready var hakkimizda_karartma: ColorRect = $HakkimizdaKarartma
@onready var hakkimizda_ekrani: Panel = $HakkimizdaEkrani
var arkaplan: TextureRect
var ilerleme_paneli: Panel
var ilerleme_baslik: Label
var ilerleme_metin: Label
var gizlilik_paneli: Panel
var gizlilik_metin: Label
var gizlilik_veri_dugmesi: Button
var gizlilik_silme_onayi := false
var tema_mesaji := ""

func _ready():
	_arkaplani_kur()
	_baslangic_logosunu_kur()
	_ilerleme_panelini_kur()
	_gizlilik_panelini_kur()

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
	_panel_dugmesi("SeviyeBaslat", "Sıradaki Seviyeyi Başlat", 342, _on_seviye_baslat_pressed)
	_panel_dugmesi("Basarimlar", "Başarımlar", 394, _on_basarimlar_pressed)
	_panel_dugmesi("Gunluk", "Günlük Görevler", 446, _on_gunluk_pressed)
	_panel_dugmesi("Kozmetik", "Kozmetik Tema", 498, _on_kozmetik_pressed)
	_panel_dugmesi("Titresim", "Titreşim", 550, _on_titresim_pressed)
	_panel_dugmesi("Kapat", "Kapat", 594, _on_ilerleme_kapat_pressed, 30)
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
	ilerleme_baslik.text = "İlerleme Merkezi"
	ilerleme_metin.text = "Sıradaki: %d. seviye / %d\nTamamlanan: %d / %d\nRekor: %d   •   En yüksek seri: %d\nYıldız: %d\n\n%s" % [Global.sonraki_acik_seviye(), SeviyeVeritabani.TOPLAM_SEVIYE, Global.ilerleme["tamamlanan_seviyeler"].size(), SeviyeVeritabani.TOPLAM_SEVIYE, Global.rekor, Global.ilerleme["en_yuksek_seri"], Global.ilerleme["kozmetik_para"], tema_mesaji]

func _on_seviye_baslat_pressed():
	$KucukSandikOlustur.baslat_seviye(Global.sonraki_acik_seviye())
	ilerleme_paneli.hide()

func _on_basarimlar_pressed():
	ilerleme_baslik.text = "Başarımlar"
	var satirlar: Array[String] = []
	for basarim in Global.BASARIMLAR:
		var acik = Global.ilerleme["basarimlar"].get(basarim["id"], false)
		satirlar.append(("✓ " if acik else "🔒 ") + basarim["ad"] + " — " + basarim["aciklama"])
	ilerleme_metin.text = "\n".join(satirlar)

func _on_gunluk_pressed():
	ilerleme_baslik.text = "Günlük Görevler"
	var satirlar: Array[String] = []
	for gorev in Global.ilerleme["gunluk"]["gorevler"]:
		var durum = "✓" if gorev["tamamlandi"] else "%d/%d" % [gorev["ilerleme"], gorev["hedef"]]
		satirlar.append("%s  %s  (+%d yıldız)" % [durum, gorev["metin"], gorev["odul"]])
	ilerleme_metin.text = "Bugün\n\n" + "\n".join(satirlar) + "\n\nGörevler cihaz tarihine göre yenilenir."

func _on_kozmetik_pressed():
	var temalar = Global.temalari_al()
	var secili_id = Global.secili_tema()["id"]
	var sonraki = temalar[0]
	for i in range(temalar.size()):
		if temalar[i]["id"] == secili_id:
			sonraki = temalar[(i + 1) % temalar.size()]
			break
	if Global.tema_al_veya_sec(sonraki["id"]):
		tema_mesaji = "Tema seçildi: %s" % sonraki["ad"]
		_arkaplan_temasini_uygula()
	else:
		tema_mesaji = "%s için %d yıldız gerekli." % [sonraki["ad"], sonraki["fiyat"]]
	_ilerleme_ozetini_goster()

func _on_titresim_pressed():
	var acik = Global.titresimi_degistir()
	tema_mesaji = "Titreşim %s." % ("açık" if acik else "kapalı")
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
	baslik.text = "Gizlilik Politikası"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gizlilik_paneli.add_child(baslik)
	gizlilik_metin = _panel_etiketi(Vector2(30, 74), Vector2(472, 404), 17)
	gizlilik_metin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gizlilik_metin.text = "Son güncelleme: 27 Ağustos 2026\n\nSandık Düştü hesap oluşturmaz; reklam, analitik veya üçüncü taraf takip hizmeti kullanmaz. Konum, kamera, mikrofon, kişi, fotoğraf ya da benzeri kişisel verileri toplamaz ve paylaşmaz.\n\nRekor, seviye ilerlemesi, başarımlar, günlük görevler ve tercihlerin yalnızca cihazınızda saklanır. Bu bilgiler internet üzerinden gönderilmez. Uygulama ek Android izni istemez. Titreşim yalnızca açık seçeneğinde ve desteklenen cihazlarda kullanılır.\n\nYerel oyun verilerinizi aşağıdan sıfırlayabilirsiniz. Bu işlem geri alınamaz. Gizlilik soruları için: tgrttaskesen@gmail.com"
	gizlilik_paneli.add_child(gizlilik_metin)
	gizlilik_veri_dugmesi = Button.new()
	gizlilik_veri_dugmesi.position = Vector2(58, 500)
	gizlilik_veri_dugmesi.size = Vector2(416, 46)
	gizlilik_veri_dugmesi.text = "Yerel Verileri Sıfırla"
	gizlilik_veri_dugmesi.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	gizlilik_veri_dugmesi.add_theme_font_size_override("font_size", 24)
	gizlilik_veri_dugmesi.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	gizlilik_veri_dugmesi.flat = true
	gizlilik_veri_dugmesi.pressed.connect(_on_gizlilik_veri_sifirla_pressed)
	gizlilik_paneli.add_child(gizlilik_veri_dugmesi)
	var kapat = Button.new()
	kapat.position = Vector2(170, 570)
	kapat.size = Vector2(192, 48)
	kapat.text = "Kapat"
	kapat.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	kapat.add_theme_font_size_override("font_size", 28)
	kapat.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88, 1))
	kapat.flat = true
	kapat.pressed.connect(_on_gizlilik_kapat_pressed)
	gizlilik_paneli.add_child(kapat)
	gizlilik_paneli.hide()

func _on_gizlilik_pressed():
	gizlilik_silme_onayi = false
	gizlilik_veri_dugmesi.text = "Yerel Verileri Sıfırla"
	gizlilik_paneli.show()

func _on_gizlilik_veri_sifirla_pressed():
	if not gizlilik_silme_onayi:
		gizlilik_silme_onayi = true
		gizlilik_veri_dugmesi.text = "Silmek için tekrar dokunun"
		return
	if Global.yerel_verileri_sifirla():
		gizlilik_silme_onayi = false
		gizlilik_veri_dugmesi.text = "Veriler sıfırlandı"
	else:
		gizlilik_silme_onayi = false
		gizlilik_veri_dugmesi.text = "Sıfırlama yapılamadı"

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
