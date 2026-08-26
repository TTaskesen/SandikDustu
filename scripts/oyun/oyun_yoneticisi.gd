extends Node2D

const SUTUN_X = [97, 287, 480]
const SANDIK_SUTUNLAR = {
	"kolay": [96, 288, 480],
	"orta": [48, 144, 240, 336, 432, 528],
	"zor": [32, 96, 160, 224, 288, 352, 416, 480, 544],
}
const SANDIK_OLCEK = {
	"kolay": 1.0,
	"orta": 0.51,
	"zor": 0.34,
}
const SANDIK_Y = 990
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

func _ready():
	yuksek_skor_label.text = "Rekor: %d" % Global.rekor
	for i in range(9):
		sandiklar.get_child(i).input_event.connect(_sandik_input.bind(i))
	_sahne_kur("kolay")
	_bildirimleri_hazirla()

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
	var sutunlar = SANDIK_SUTUNLAR[zorluk_adi]
	var olcek = SANDIK_OLCEK[zorluk_adi]
	sandik_olcekleri = []
	for i in range(9):
		var sandik = sandiklar.get_child(i)
		if i < sutunlar.size():
			sandik.visible = true
			sandik.position = Vector2(sutunlar[i], SANDIK_Y)
		else:
			sandik.visible = false
		sandik_olcekleri.append(olcek)
	for i in range(3):
		ucgenler.get_child(i).visible = true
		ucgenler.get_child(i).scale = Vector2.ONE
	_secimi_temizle()
	_renk_sirasini_hazirla()

func _cesit_sayisi() -> int:
	return SANDIK_SUTUNLAR[aktif_zorluk].size()

func _renk_sirasini_hazirla():
	renk_sirasi = []
	for i in range(_cesit_sayisi()):
		renk_sirasi.append(sandiklar.get_child(i).renk)
	renk_sirasi.shuffle()

func _process(delta):
	if not kontrol or not oyun_devam:
		return
	for sutun in firlatilan_sandiklar.keys():
		var firlatilan = firlatilan_sandiklar[sutun]
		firlatilan.position.y -= FIRLATMA_HIZI * delta
		if firlatilan.position.y < -150:
			if dusen_sandiklar.has(sutun):
				_ipucu_goster("Yanlış renk!")
			else:
				_ipucu_goster("Yanlış sütun!")
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
		_ipucu_goster("Önce bir renk seç!")
		return
	if firlatilan_sandiklar.has(sutun):
		return
	var firlatilan = kucuk_sahneler[secili_renk].instantiate()
	firlatilan.speed = 0
	firlatilan.firlatildi = true
	firlatilan.position = Vector2(SUTUN_X[sutun], UCGEN_Y)
	$Projectiles.add_child(firlatilan)
	firlatilan_sandiklar[sutun] = firlatilan

func ekrani_ac():
	$SesTik.play()
	var tween = _menu_tweeni()
	tween.tween_property(basla_menu, "position", Vector2(0, 300), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 300), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2(576, -100), MENU_SURE)
	baslik.show()

func zor_menu_ac():
	$SesTik.play()
	var tween = _menu_tweeni()
	tween.tween_property(basla_menu, "position", Vector2(-576, 300), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(0, 300), MENU_SURE)

func oyunu_baslat(interval: float, dusme_hizi: int, zorluk_adi: String):
	$SesTik.play()
	oyunu_sifirla()
	kontrol = true
	son_interval = interval
	son_hiz = dusme_hizi
	hiz = dusme_hizi
	Global.zorluk = zorluk_adi
	_sahne_kur(zorluk_adi)
	var tween = _menu_tweeni()
	tween.tween_property(zor_menu, "position", Vector2(576, 300), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, -232), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, 430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2.ZERO, MENU_SURE)
	baslik.hide()
	kucuk_sandik_olustur()

func tekrar_oyna():
	oyunu_baslat(son_interval, son_hiz, Global.zorluk)

func oyunu_sifirla():
	oyun_devam = true
	kontrol = false
	skor = 0
	renk_sirasi = []
	dusen_sandiklar.clear()
	firlatilan_sandiklar.clear()
	_secimi_temizle()
	sayac_label.text = "0"
	for c in $Projectiles.get_children():
		c.queue_free()
	$Timer.stop()

func oyun_sonu():
	if not kontrol or not oyun_devam:
		return
	oyun_devam = false
	kontrol = false
	_secimi_temizle()
	for sutun in dusen_sandiklar.keys():
		dusen_sandiklar[sutun].queue_free()
	for sutun in firlatilan_sandiklar.keys():
		firlatilan_sandiklar[sutun].queue_free()
	dusen_sandiklar.clear()
	firlatilan_sandiklar.clear()
	Global.rekoru_guncelle(skor)
	yuksek_skor_label.text = "Rekor: %d" % Global.rekor
	$SesKaybetme.play()
	$Timer.stop()
	var tween = _menu_tweeni()
	tween.tween_property(tekrar_label, "position", Vector2(30, 400), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 300), MENU_SURE)
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
	gecis_label.text = "OYUN BİTTİ!!!!!"
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
	yuksek_skor_label.text = "Rekor: %d" % Global.rekor
	var tween = _menu_tweeni()
	tween.tween_property(basla_menu, "position", Vector2(0, 300), MENU_SURE)
	tween.tween_property(zor_menu, "position", Vector2(576, 300), MENU_SURE)
	tween.tween_property(kolay_menu, "position", Vector2(0, 0), MENU_SURE)
	tween.tween_property(sayac, "position", Vector2(0, -430), MENU_SURE)
	tween.tween_property(tekrar_label, "position", Vector2(576, -150), MENU_SURE)
	tween.tween_property(self, "position", Vector2(576, -100), MENU_SURE)
	baslik.show()

func kucuk_sandik_olustur():
	if not kontrol or not oyun_devam:
		return
	if dusen_sandiklar.size() > 0:
		return
	if renk_sirasi.is_empty():
		_renk_sirasini_hazirla()
	var sutun = randi_range(0, 2)
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
		sayac_label.text = str(skor)
		$SesYakalama.play()
		if Global.rekoru_guncelle(skor):
			yuksek_skor_label.text = "Rekor: %d" % Global.rekor
		if aktif_zorluk == "kolay" and skor >= 15:
			_gecis_bildirimi("Orta'ya Geçtin!")
			call_deferred("oyunu_baslat", 2.0, 140, "orta")
			return
		if aktif_zorluk == "orta" and skor >= 30:
			_gecis_bildirimi("Zor'a Geçtin!")
			call_deferred("oyunu_baslat", 1.5, 190, "zor")
			return
		if aktif_zorluk == "zor" and skor >= 100:
			_oyun_bitti_ekrani()
			return
		_partikul_patlat(dusen.global_position, RENK_RENKLERI.get(dusen.renk, Color.WHITE))
		dusen.queue_free()
		firlatilan.queue_free()
		dusen_sandiklar.erase(sutun)
		firlatilan_sandiklar.erase(sutun)
		if dusen_sandiklar.is_empty():
			$Timer.start()

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
