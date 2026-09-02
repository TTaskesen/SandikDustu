extends Node2D

const SeviyeVeritabani = preload("res://scripts/seviye_veritabani.gd")

const SUTUN_X = [97, 287, 480]
const SANDIK_Y = 990
const SANDIK_SATIR_ARALIGI = 96
const ANDROID_MIN_ALT_GUVENLIK_BOSLUGU = 72.0
const ANDROID_ALT_BOSLUK_AZALTMA_ORANI = 0.35
const OYUN_ALANI_ALT_MARJI = 24.0
const SANDIK_DIZILIMLERI = {
	"kolay": [
		Vector2(96, SANDIK_Y), Vector2(288, SANDIK_Y), Vector2(480, SANDIK_Y),
	],
	"orta": [
		Vector2(96, SANDIK_Y - SANDIK_SATIR_ARALIGI), Vector2(288, SANDIK_Y - SANDIK_SATIR_ARALIGI), Vector2(480, SANDIK_Y - SANDIK_SATIR_ARALIGI),
		Vector2(96, SANDIK_Y), Vector2(288, SANDIK_Y), Vector2(480, SANDIK_Y),
	],
	"zor": [
		Vector2(96, SANDIK_Y - SANDIK_SATIR_ARALIGI * 2), Vector2(288, SANDIK_Y - SANDIK_SATIR_ARALIGI * 2), Vector2(480, SANDIK_Y - SANDIK_SATIR_ARALIGI * 2),
		Vector2(96, SANDIK_Y - SANDIK_SATIR_ARALIGI), Vector2(288, SANDIK_Y - SANDIK_SATIR_ARALIGI), Vector2(480, SANDIK_Y - SANDIK_SATIR_ARALIGI),
		Vector2(96, SANDIK_Y), Vector2(288, SANDIK_Y), Vector2(480, SANDIK_Y),
	],
}
const SANDIK_OLCEK = {
	"kolay": 1.0,
	"orta": 1.0,
	"zor": 1.0,
}
const UCGEN_Y = 892
const MENU_SURE = 0.6
const FIRLATMA_HIZI = 600.0
const CARPISMA_ESIGI = 40.0

const RENK_RENKLERI = {
	"acik_yesil": Color("#a9dfa0"),
	"kirmizi": Color("#e26060"),
	"mavi": Color("#6a9fe8"),
	"mor": Color("#b07ae0"),
	"pembe": Color("#f08ac0"),
	"sari": Color("#f0d060"),
	"turkuaz": Color("#5fd6cf"),
	"turuncu": Color("#f09a50"),
	"yesil": Color("#7fd060"),
}

var kucuk_sahneler = {
	"acik_yesil": preload("res://scenes/kucukSandik/kucuk_acik_yesil_sandik.tscn"),
	"kirmizi": preload("res://scenes/kucukSandik/kucuk_kirmizi_sandik.tscn"),
	"mavi": preload("res://scenes/kucukSandik/kucuk_mavi_sandik.tscn"),
	"mor": preload("res://scenes/kucukSandik/kucuk_mor_sandik.tscn"),
	"pembe": preload("res://scenes/kucukSandik/kucuk_pembe_sandik.tscn"),
	"sari": preload("res://scenes/kucukSandik/kucuk_sari_sandik.tscn"),
	"turkuaz": preload("res://scenes/kucukSandik/kucuk_turkuaz_sandik.tscn"),
	"turuncu": preload("res://scenes/kucukSandik/kucuk_turuncu_sandik.tscn"),
	"yesil": preload("res://scenes/kucukSandik/kucuk_yesil_sandik.tscn"),
}

@onready var kolay_menu: Node2D = $"../KolayMenu"
@onready var baslik: Label = $"../MenuButonlar/UI/Baslik"
@onready var sayac: Node2D = $"../MenuButonlar/Sayac"
@onready var sayac_label: Label = $"../MenuButonlar/Sayac/SayacLabel"
@onready var yuksek_skor_label: Label = $"../MenuButonlar/Sayac/YüksekSkorLabel"
@onready var basla_menu: Control = $"../MenuButonlar/BaslaMenuButonlar/BaslaMenu"
@onready var zor_menu: Control = $"../MenuButonlar/ZorMenuButonlar/ZorMenu"
@onready var tekrar_label: Button = $"../MenuButonlar/TekrarDene/TekrarLabel"
@onready var sandiklar: Node2D = $"../KolayMenu/MenuEkrani/Sandiklar64"
@onready var ucgenler: Node2D = $"../KolayMenu/MenuEkrani/Üçgenler"
@onready var bariyer: Area2D = $"../KolayMenu/MenuEkrani/Bariyer"

var kontrol = false
var oyun_devam = true
var dusen_sandiklar = {}
var firlatilan_sandiklar = {}
var secili_renk = ""
var aktif_zorluk = "kolay"
var renk_sirasi = []
var sandik_olcekleri = []
var skor = 0
var hiz = 100
var son_interval = 3.0
var son_hiz = 100
var ipucu_label: Label
var gecis_label: Label
var android_alt_guvenlik_boslugu = 0.0
var seviye_bilgi_label: Label
var ogretici_label: Label
var geri_bildirim_katmani: CanvasLayer
var seviye_modu := false
var aktif_seviye := 0
var seviye_hedefi := 0
var seviye_hata_toleransi := 0
var seviye_hatalari := 0
var aktif_renk_dizilimi: Array = []
var seri := 0
var egitim_aktif := false

func _ready():
	_android_guvenli_alani_hazirla()
	Global.dil_degisti.connect(_on_dil_degisti)
	_yuksek_skoru_yenile()
	for i in range(9):
		sandiklar.get_child(i).input_event.connect(_sandik_input.bind(i))
	_sahne_kur("kolay")
	_bildirimleri_hazirla()
	_oyun_hudunu_hazirla()

func _t(anahtar: String, degerler: Dictionary = {}) -> String:
	return Global.cevir(anahtar, degerler)

func _yuksek_skoru_yenile():
	yuksek_skor_label.text = _t("best_score", {"score": Global.rekor})

func _on_dil_degisti(_kod: String):
	_yuksek_skoru_yenile()
	_seviye_hudunu_guncelle()
	if egitim_aktif:
		ogretici_label.text = _t("tutorial")

func _android_guvenli_alani_hazirla():
	if OS.get_name() != "Android":
		android_alt_guvenlik_boslugu = 0.0
		return
	var ekran_boyutu = DisplayServer.screen_get_size()
	var guvenli_alan = DisplayServer.get_display_safe_area()
	var hesaplanan_bosluk = 0.0
	if ekran_boyutu.y > 0:
		var fiziksel_alt_bosluk = maxf(0.0, ekran_boyutu.y - guvenli_alan.end.y)
		hesaplanan_bosluk = fiziksel_alt_bosluk * get_viewport().get_visible_rect().size.y / ekran_boyutu.y
	# Bazı Android gezinme çubukları güvenli alan bilgisinde görünmez; seçilebilir alanı yine koru.
	android_alt_guvenlik_boslugu = maxf(ANDROID_MIN_ALT_GUVENLIK_BOSLUGU, hesaplanan_bosluk)

func _oyun_alani_konumu() -> Vector2:
	# Geniş ekranlı Android cihazlarda alt boşluğu cihazın güvenli alanına göre
	# hesapla; kullanılabilir oyun alanını %35 artırmak için boşluğu azalt.
	var gorunur_yukseklik = get_viewport().get_visible_rect().size.y
	var buyuk_sandik_alt_siniri = SANDIK_Y + 94.0
	var alt_bosluk = android_alt_guvenlik_boslugu + OYUN_ALANI_ALT_MARJI
	if OS.get_name() == "Android":
		alt_bosluk *= 1.0 - ANDROID_ALT_BOSLUK_AZALTMA_ORANI
	var hedef_alt = gorunur_yukseklik - alt_bosluk
	return Vector2(0, hedef_alt - buyuk_sandik_alt_siniri)

func _giris_logosunu_goster(gorunur: bool):
	var giris_logosu = get_node_or_null("../MenuButonlar/UI/BaslangicLogo") as CanvasItem
	if giris_logosu:
		giris_logosu.visible = gorunur
	var dil_sekmeleri = get_node_or_null("../MenuButonlar/UI/DilSekmeleri") as CanvasItem
	if dil_sekmeleri:
		dil_sekmeleri.visible = gorunur

func _bildirimleri_hazirla():
	var katman = CanvasLayer.new()
	katman.layer = 10
	add_child(katman)
	var font = preload("res://fonts/font-80.tres")
	ipucu_label = Label.new()
	ipucu_label.position = Vector2(88, 190)
	ipucu_label.size = Vector2(400, 80)
	ipucu_label.add_theme_font_override("font", font)
	ipucu_label.add_theme_font_size_override("font_size", 42)
	ipucu_label.add_theme_color_override("font_color", Color(0.94, 0.94, 0.9, 1))
	ipucu_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ipucu_label.visible = false
	katman.add_child(ipucu_label)
	gecis_label = Label.new()
	gecis_label.position = Vector2(38, 280)
	gecis_label.size = Vector2(500, 130)
	gecis_label.add_theme_font_override("font", font)
	gecis_label.add_theme_font_size_override("font_size", 72)
	gecis_label.add_theme_color_override("font_color", Color(0.95, 0.83, 0.4, 1))
	gecis_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gecis_label.visible = false
	katman.add_child(gecis_label)

func _oyun_hudunu_hazirla():
	geri_bildirim_katmani = CanvasLayer.new()
	geri_bildirim_katmani.layer = 9
	add_child(geri_bildirim_katmani)
	seviye_bilgi_label = Label.new()
	seviye_bilgi_label.position = Vector2(120, 82)
	seviye_bilgi_label.size = Vector2(336, 72)
	seviye_bilgi_label.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	seviye_bilgi_label.add_theme_font_size_override("font_size", 27)
	seviye_bilgi_label.add_theme_color_override("font_color", Color(0.94, 0.94, 0.9, 1))
	seviye_bilgi_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seviye_bilgi_label.visible = false
	geri_bildirim_katmani.add_child(seviye_bilgi_label)
	ogretici_label = Label.new()
	ogretici_label.position = Vector2(48, 175)
	ogretici_label.size = Vector2(480, 110)
	ogretici_label.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	ogretici_label.add_theme_font_size_override("font_size", 32)
	ogretici_label.add_theme_color_override("font_color", Color("#f4e0a2"))
	ogretici_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ogretici_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ogretici_label.visible = false
	geri_bildirim_katmani.add_child(ogretici_label)

func _seviye_hudunu_guncelle():
	if not seviye_modu:
		seviye_bilgi_label.visible = false
		return
	seviye_bilgi_label.text = _t("level_hud", {"level": aktif_seviye, "score": skor, "goal": seviye_hedefi, "mistakes": seviye_hatalari, "allowed": seviye_hata_toleransi})
	seviye_bilgi_label.visible = true

func _puan_sicramasi(pozisyon: Vector2, metin: String, renk: Color):
	var etiket = Label.new()
	etiket.position = pozisyon + Vector2(-35, -55)
	etiket.size = Vector2(70, 45)
	etiket.text = metin
	etiket.add_theme_font_override("font", preload("res://fonts/font-80.tres"))
	etiket.add_theme_font_size_override("font_size", 34)
	etiket.add_theme_color_override("font_color", renk)
	etiket.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	geri_bildirim_katmani.add_child(etiket)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(etiket, "position:y", etiket.position.y - 55, 0.45)
	tween.tween_property(etiket, "modulate:a", 0.0, 0.45)
	tween.chain().tween_callback(etiket.queue_free)

func _titreşim(veri_suresi: int):
	if OS.get_name() == "Android" and Global.titresim_acik_mi():
		Input.vibrate_handheld(veri_suresi)

func _ipucu_goster(metin: String):
	ipucu_label.text = metin
	ipucu_label.modulate.a = 0.0
	ipucu_label.visible = true
	var tween = create_tween()
	tween.tween_property(ipucu_label, "modulate:a", 1.0, 0.15)
	tween.tween_interval(0.5)
	tween.tween_property(ipucu_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): ipucu_label.visible = false)

func _gecis_bildirimi(metin: String):
	$SesGecis.play()
	gecis_label.text = metin
	gecis_label.modulate.a = 0.0
	gecis_label.scale = Vector2(0.6, 0.6)
	gecis_label.visible = true
	var tween = create_tween()
	tween.tween_property(gecis_label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(gecis_label, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_interval(0.8)
	tween.tween_property(gecis_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): gecis_label.visible = false)

func _sandik_input(_viewport: Node, event: InputEvent, _shape_idx: int, index: int):
	if event is InputEventScreenTouch and event.pressed:
		_renk_sec(index)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_renk_sec(index)

func _renk_sec(index: int):
	if not kontrol or not oyun_devam:
		return
	var sandik = sandiklar.get_child(index)
	if not sandik.visible:
		return
	if secili_renk == sandik.renk:
		return
	_secimi_temizle()
	secili_renk = sandik.renk
	var temel = sandik_olcekleri[index] if index < sandik_olcekleri.size() else 1.0
	sandik.scale = Vector2.ONE * temel * 1.15
	var pop = create_tween()
	pop.tween_property(sandik, "scale", Vector2.ONE * temel, 0.25)

func _secimi_temizle():
	secili_renk = ""
	for i in range(9):
		var temel = sandik_olcekleri[i] if i < sandik_olcekleri.size() else 1.0
		sandiklar.get_child(i).scale = Vector2.ONE * temel

func _sahne_kur(zorluk_adi: String):
	aktif_zorluk = zorluk_adi
	var dizilim = SANDIK_DIZILIMLERI[zorluk_adi]
	var olcek = SANDIK_OLCEK[zorluk_adi]
	sandik_olcekleri = []
	for i in range(9):
		var sandik = sandiklar.get_child(i)
		if i < dizilim.size() and (not egitim_aktif or i == 0):
			sandik.visible = true
			sandik.position = dizilim[i]
		else:
			sandik.visible = false
		sandik_olcekleri.append(olcek)
	var satir_sayisi = _satir_sayisi()
	# Kaybetme sınırı, üçgenlerin altında sabit kalır; ek satırlarda birlikte yukarı taşınır.
	bariyer.position.y = -(satir_sayisi - 1) * SANDIK_SATIR_ARALIGI
	for i in range(3):
		var ucgen = ucgenler.get_child(i)
		ucgen.visible = not egitim_aktif or i == 0
		ucgen.scale = Vector2.ONE
		ucgen.position.y = UCGEN_Y - (satir_sayisi - 1) * SANDIK_SATIR_ARALIGI
	_secimi_temizle()
	_renk_sirasini_hazirla()

func _cesit_sayisi() -> int:
	return SANDIK_DIZILIMLERI[aktif_zorluk].size()

func _satir_sayisi() -> int:
	return int(_cesit_sayisi() / 3.0)

func _renk_sirasini_hazirla():
	renk_sirasi = []
	if not aktif_renk_dizilimi.is_empty():
		for renk in aktif_renk_dizilimi:
			for sandik in sandiklar.get_children():
				if sandik.visible and sandik.renk == renk:
					renk_sirasi.append(renk)
					break
		if not renk_sirasi.is_empty():
			return
	for sandik in sandiklar.get_children():
		if sandik.visible:
			renk_sirasi.append(sandik.renk)
	renk_sirasi.shuffle()

func _process(delta):
	if not kontrol or not oyun_devam:
		return
	for sutun in firlatilan_sandiklar.keys():
		var firlatilan = firlatilan_sandiklar[sutun]
		firlatilan.position.y -= FIRLATMA_HIZI * delta
		if firlatilan.position.y < -150:
			if dusen_sandiklar.has(sutun):
				yanlis_hamle(_t("wrong_color"))
			else:
				yanlis_hamle(_t("wrong_column"))
			firlatilan.queue_free()
			firlatilan_sandiklar.erase(sutun)
			continue
		if dusen_sandiklar.has(sutun):
			var dusen = dusen_sandiklar[sutun]
			if absf(firlatilan.position.y - dusen.position.y) <= CARPISMA_ESIGI:
				if firlatilan.renk == dusen.renk:
					cozumle(sutun)

func firlat(sutun: int):
	if not kontrol or not oyun_devam:
		return
	if secili_renk == "":
		_ipucu_goster(_t("choose_color"))
		return
	if firlatilan_sandiklar.has(sutun):
		return
	var firlatilan = kucuk_sahneler[secili_renk].instantiate()
	firlatilan.speed = 0
	firlatilan.firlatildi = true
	firlatilan.position = ucgenler.get_child(sutun).global_position
	$Projectiles.add_child(firlatilan)
	firlatilan_sandiklar[sutun] = firlatilan

func ekrani_ac():
	$SesTik.play()
	_giris_logosunu_goster(true)
	basla_menu.show()
	var tween = _menu_tweeni()
	tween.tween_property(basla_menu, "position", Vector2(0, 320), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 320), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2(576, -100), MENU_SURE)
	baslik.show()
	seviye_bilgi_label.visible = false
	ogretici_label.visible = false

func zor_menu_ac():
	$SesTik.play()
	_giris_logosunu_goster(true)
	var tween = _menu_tweeni()
	tween.tween_property(basla_menu, "position", Vector2(-576, 320), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(0, 320), MENU_SURE)

func oyunu_baslat(interval: float, dusme_hizi: int, zorluk_adi: String):
	seviye_modu = false
	aktif_seviye = 0
	aktif_renk_dizilimi = []
	egitim_aktif = false
	_oyunu_baslat_ozel(interval, dusme_hizi, zorluk_adi)

func baslat_seviye(seviye_no: int):
	if not Global.seviye_acik_mi(seviye_no):
		_ipucu_goster(_t("level_locked"))
		return
	var veri = SeviyeVeritabani.seviyeyi_al(seviye_no)
	seviye_modu = true
	aktif_seviye = seviye_no
	seviye_hedefi = int(veri["hedef_skor"])
	seviye_hata_toleransi = int(veri["hata_toleransi"])
	seviye_hatalari = 0
	aktif_renk_dizilimi = veri["renk_dizilimi"].duplicate()
	egitim_aktif = not Global.ogretici_tamamlandi_mi()
	if egitim_aktif:
		seviye_hedefi = 1
		seviye_hata_toleransi = 99
		aktif_renk_dizilimi = ["acik_yesil"]
		_oyunu_baslat_ozel(1.4, 60, "kolay")
		ogretici_label.text = _t("tutorial")
		ogretici_label.visible = true
	else:
		_oyunu_baslat_ozel(float(veri["interval"]), int(veri["dusme_hizi"]), str(veri["zorluk"]))

func _oyunu_baslat_ozel(interval: float, dusme_hizi: int, zorluk_adi: String):
	$SesTik.play()
	oyunu_sifirla()
	_giris_logosunu_goster(false)
	# Seviye merkezi ana menüden doğrudan oyun başlatabilir; menü oyun alanına taşmamalı.
	basla_menu.hide()
	kolay_menu.show()
	kontrol = true
	son_interval = interval
	son_hiz = dusme_hizi
	hiz = dusme_hizi
	$Timer.wait_time = interval
	Global.zorluk = zorluk_adi
	_sahne_kur(zorluk_adi)
	var tween = _menu_tweeni()
	tween.tween_property(zor_menu, "position", Vector2(576, 320), MENU_SURE)
	tween.tween_property(kolay_menu, "position", _oyun_alani_konumu(), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, 430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2.ZERO, MENU_SURE)
	baslik.hide()
	_seviye_hudunu_guncelle()
	kucuk_sandik_olustur()

func tekrar_oyna():
	if seviye_modu and aktif_seviye > 0:
		baslat_seviye(aktif_seviye)
		return
	oyunu_baslat(son_interval, son_hiz, Global.zorluk)

func oyunu_sifirla():
	oyun_devam = true
	kontrol = false
	# Geri ile ana menüye dönüldüğünde önceki zorluk düzeni görünür kalmasın.
	kolay_menu.hide()
	skor = 0
	renk_sirasi = []
	dusen_sandiklar.clear()
	firlatilan_sandiklar.clear()
	_secimi_temizle()
	sayac_label.text = "0"
	seri = 0
	seviye_hatalari = 0
	for c in $Projectiles.get_children():
		c.queue_free()
	$Timer.stop()

func oyun_sonu():
	if not kontrol or not oyun_devam:
		return
	oyun_devam = false
	kontrol = false
	kolay_menu.hide()
	_secimi_temizle()
	for sutun in dusen_sandiklar.keys():
		dusen_sandiklar[sutun].queue_free()
	for sutun in firlatilan_sandiklar.keys():
		firlatilan_sandiklar[sutun].queue_free()
	dusen_sandiklar.clear()
	firlatilan_sandiklar.clear()
	Global.rekoru_guncelle(skor)
	Global.basarimlari_guncelle()
	_yuksek_skoru_yenile()
	$SesKaybetme.play()
	$Timer.stop()
	seviye_bilgi_label.visible = false
	ogretici_label.visible = false
	var tween = _menu_tweeni()
	tween.tween_property(tekrar_label, "position", Vector2(30, 400), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 320), MENU_SURE)
	tween.tween_property(self, "position", Vector2(576, -100), MENU_SURE)

func _oyun_bitti_ekrani():
	oyun_devam = false
	kontrol = false
	_secimi_temizle()
	for sutun in dusen_sandiklar.keys():
		dusen_sandiklar[sutun].queue_free()
	for sutun in firlatilan_sandiklar.keys():
		firlatilan_sandiklar[sutun].queue_free()
	dusen_sandiklar.clear()
	firlatilan_sandiklar.clear()
	$Timer.stop()
	$SesGecis.play()
	gecis_label.text = _t("game_over")
	gecis_label.add_theme_font_size_override("font_size", 50)
	gecis_label.add_theme_color_override("font_color", Color(0.96, 0.28, 0.22, 1))
	gecis_label.modulate.a = 0.0
	gecis_label.scale = Vector2(0.6, 0.6)
	gecis_label.visible = true
	var tween = create_tween()
	tween.tween_property(gecis_label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(gecis_label, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_interval(2.0)
	tween.tween_callback(_ana_menuye_don)

func _ana_menuye_don():
	gecis_label.visible = false
	gecis_label.add_theme_font_size_override("font_size", 72)
	gecis_label.add_theme_color_override("font_color", Color(0.95, 0.83, 0.4, 1))
	Global.rekoru_guncelle(skor)
	_yuksek_skoru_yenile()
	var tween = _menu_tweeni()
	basla_menu.show()
	tween.tween_property(basla_menu, "position", Vector2(0, 320), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 320), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2(576, -100), MENU_SURE)
	baslik.show()
	seviye_bilgi_label.visible = false
	ogretici_label.visible = false

func kucuk_sandik_olustur():
	if not kontrol or not oyun_devam:
		return
	if dusen_sandiklar.size() > 0:
		return
	if renk_sirasi.is_empty():
		_renk_sirasini_hazirla()
	# Öğreticide tek üçgen görünür; düşen sandık da aynı sütunda olmalı.
	var sutun = 0 if egitim_aktif else randi_range(0, 2)
	var renk = renk_sirasi.pop_back()
	var dusen = kucuk_sahneler[renk].instantiate()
	dusen.speed = hiz
	dusen.position = Vector2(SUTUN_X[sutun], -100)
	$Projectiles.add_child(dusen)
	dusen_sandiklar[sutun] = dusen

func cozumle(sutun: int):
	var firlatilan = firlatilan_sandiklar.get(sutun)
	var dusen = dusen_sandiklar.get(sutun)
	if firlatilan and dusen and firlatilan.renk == dusen.renk:
		skor += 1
		seri += 1
		sayac_label.text = str(skor)
		$SesYakalama.play()
		_titreşim(18)
		_puan_sicramasi(dusen.global_position, "+1", RENK_RENKLERI.get(dusen.renk, Color.WHITE))
		Global.sandik_yakalandi(seri)
		Global.gunluk_hatasiz_seri(seri)
		if Global.rekoru_guncelle(skor):
			_yuksek_skoru_yenile()
		Global.basarimlari_guncelle()
		_seviye_hudunu_guncelle()
		_partikul_patlat(dusen.global_position, RENK_RENKLERI.get(dusen.renk, Color.WHITE))
		dusen.queue_free()
		firlatilan.queue_free()
		dusen_sandiklar.erase(sutun)
		firlatilan_sandiklar.erase(sutun)
		if egitim_aktif:
			Global.ogreticiyi_tamamla()
			egitim_aktif = false
			ogretici_label.visible = false
			_ipucu_goster(_t("great_next"))
			call_deferred("baslat_seviye", aktif_seviye)
			return
		if seviye_modu and skor >= seviye_hedefi:
			_seviye_tamamla()
			return
		if not seviye_modu and aktif_zorluk == "kolay" and skor >= 15:
			_gecis_bildirimi(_t("medium_unlocked"))
			call_deferred("oyunu_baslat", 1.0, 150, "orta")
			return
		if not seviye_modu and aktif_zorluk == "orta" and skor >= 30:
			_gecis_bildirimi(_t("hard_unlocked"))
			call_deferred("oyunu_baslat", 0.75, 100, "zor")
			return
		if not seviye_modu and aktif_zorluk == "zor" and skor >= 100:
			_oyun_bitti_ekrani()
			return
		if dusen_sandiklar.is_empty():
			$Timer.start()

func yanlis_hamle(mesaj: String):
	seri = 0
	_ipucu_goster(mesaj)
	_titreşim(35)

func sandik_kacti():
	if not kontrol or not oyun_devam:
		return
	seri = 0
	seviye_hatalari += 1
	_titreşim(45)
	if seviye_modu and seviye_hatalari <= seviye_hata_toleransi:
		_ipucu_goster(_t("mistakes", {"mistakes": seviye_hatalari, "allowed": seviye_hata_toleransi}))
		for dusen in dusen_sandiklar.values():
			dusen.queue_free()
		dusen_sandiklar.clear()
		_seviye_hudunu_guncelle()
		$Timer.start()
		return
	oyun_sonu()

func _seviye_tamamla():
	kontrol = false
	oyun_devam = false
	$Timer.stop()
	var yeni_basarimlar = Global.seviye_tamamla(aktif_seviye, skor, seviye_hatalari == 0)
	var odul = int(SeviyeVeritabani.seviyeyi_al(aktif_seviye)["odul"])
	_gecis_bildirimi(_t("level_complete", {"level": aktif_seviye, "stars": odul}))
	if not yeni_basarimlar.is_empty():
		_ipucu_goster(_t("achievement_unlocked", {"name": Global.basarim_adi(yeni_basarimlar[0])}))
	seviye_bilgi_label.visible = false
	if aktif_seviye < SeviyeVeritabani.TOPLAM_SEVIYE:
		get_tree().create_timer(1.4).timeout.connect(func(): baslat_seviye(aktif_seviye + 1))
	else:
		get_tree().create_timer(1.4).timeout.connect(_ana_menuye_don)

func _menu_tweeni() -> Tween:
	var tween = create_tween()
	tween.set_parallel()
	return tween

static var _partikul_dokusu: Texture2D

func _partikul_patlat(pozisyon: Vector2, renk: Color):
	var partikul = CPUParticles2D.new()
	partikul.position = pozisyon
	partikul.one_shot = true
	partikul.explosiveness = 1.0
	partikul.amount = 20
	partikul.lifetime = 0.6
	partikul.direction = Vector2(0, -1)
	partikul.spread = 180.0
	partikul.gravity = Vector2(0, 350)
	partikul.initial_velocity_min = 120.0
	partikul.initial_velocity_max = 280.0
	partikul.scale_amount_min = 1.0
	partikul.scale_amount_max = 2.0
	partikul.texture = _partikul_dokusu_al()
	partikul.color_ramp = _renk_rampi(renk)
	add_child(partikul)
	partikul.finished.connect(partikul.queue_free)

static func _partikul_dokusu_al() -> Texture2D:
	if _partikul_dokusu == null:
		var resim = Image.create(8, 8, false, Image.FORMAT_RGBA8)
		resim.fill(Color.WHITE)
		_partikul_dokusu = ImageTexture.create_from_image(resim)
	return _partikul_dokusu

static func _renk_rampi(renk: Color) -> Gradient:
	var rampa = Gradient.new()
	rampa.set_color(0, renk)
	rampa.set_color(1, Color(renk.r, renk.g, renk.b, 0))
	return rampa
