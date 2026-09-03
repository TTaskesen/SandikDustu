extends Area2D

@export var speed: int = 100
@export var renk: String = "mavi"

const KENAR_YARICAP := 43.0
const CUBUK_KALINLIGI := 12.0
const RENK_DEGISIM_SURESI := 2.0
const RENKLER := {
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

var firlatildi := false
var renk_degisimi_gecen_sure := 0.0
var renkli_kenarlar: Array = [["acik_yesil"], ["kirmizi"], ["mavi"]]
var renk_havuzu := ["acik_yesil", "kirmizi", "mavi"]
var renk_degisimi_suresi := RENK_DEGISIM_SURESI
var kenar_basina_renk_sayisi := 1

func renk_havuzunu_ayarla(yeni_havuz: Array, yeni_sure: float, yeni_kenar_basina_renk_sayisi: int):
	renk_havuzu = yeni_havuz.duplicate()
	renk_degisimi_suresi = yeni_sure
	kenar_basina_renk_sayisi = clampi(yeni_kenar_basina_renk_sayisi, 1, 3)
	_kenar_renklerini_karistir()

func _ready():
	_kenar_renklerini_karistir()
	queue_redraw()

func _process(delta):
	if not firlatildi:
		position.y += speed * delta
	renk_degisimi_gecen_sure += delta
	if renk_degisimi_gecen_sure >= renk_degisimi_suresi:
		renk_degisimi_gecen_sure = 0.0
		_kenar_renklerini_karistir()

func _kenar_renklerini_karistir():
	# Üst kenar beyazdır; diğer üç kenar, geçerli zorluktaki tüm renkleri taşır.
	var secenekler = renk_havuzu.duplicate()
	secenekler.shuffle()
	renkli_kenarlar = []
	for kenar in range(3):
		var baslangic = kenar * kenar_basina_renk_sayisi
		renkli_kenarlar.append(secenekler.slice(baslangic, baslangic + kenar_basina_renk_sayisi))
	# Oyuncu, sabit sandığın alt kenarında görünen renklerden birini seçebilir.
	renk = renkli_kenarlar[1][0]
	queue_redraw()

func eslesir_mi(secili_renk: String) -> bool:
	return renkli_kenarlar.size() > 1 and renkli_kenarlar[1].has(secili_renk)

func _draw():
	var dis_kutu = Rect2(Vector2(-KENAR_YARICAP, -KENAR_YARICAP), Vector2(KENAR_YARICAP * 2.0, KENAR_YARICAP * 2.0))
	# İç alan boş ve saydamdır; yalnızca renkli kenar çubukları yer değiştirir.
	draw_rect(dis_kutu, Color("#e9edf6"), false, 3.0)
	draw_rect(Rect2(-KENAR_YARICAP, -KENAR_YARICAP, KENAR_YARICAP * 2.0, CUBUK_KALINLIGI), Color.WHITE, true)
	_renkli_kenari_ciz(Rect2(KENAR_YARICAP - CUBUK_KALINLIGI, -KENAR_YARICAP, CUBUK_KALINLIGI, KENAR_YARICAP * 2.0), renkli_kenarlar[0], false)
	_renkli_kenari_ciz(Rect2(-KENAR_YARICAP, KENAR_YARICAP - CUBUK_KALINLIGI, KENAR_YARICAP * 2.0, CUBUK_KALINLIGI), renkli_kenarlar[1], true)
	_renkli_kenari_ciz(Rect2(-KENAR_YARICAP, -KENAR_YARICAP, CUBUK_KALINLIGI, KENAR_YARICAP * 2.0), renkli_kenarlar[2], false)

func _renkli_kenari_ciz(alan: Rect2, renkler: Array, yatay: bool):
	if renkler.is_empty():
		return
	for indeks in renkler.size():
		var parca: Rect2
		if yatay:
			parca = Rect2(alan.position + Vector2(alan.size.x * indeks / renkler.size(), 0), Vector2(alan.size.x / renkler.size(), alan.size.y))
		else:
			parca = Rect2(alan.position + Vector2(0, alan.size.y * indeks / renkler.size()), Vector2(alan.size.x, alan.size.y / renkler.size()))
		draw_rect(parca, RENKLER[renkler[indeks]], true)
