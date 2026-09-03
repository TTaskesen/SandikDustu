extends Area2D

@export var speed: int = 100
@export var renk: String = "mavi"

const DONUS_SURESI := 2.0
const KENAR_KALINLIGI := 12.0
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
var renk_havuzu: Array = ["acik_yesil", "kirmizi", "mavi"]
var kenar_basina_renk_sayisi := 1
var renkli_kenarlar: Array = []
var hedef_kenar := 1
var gecen_sure := 0.0

func renk_havuzunu_ayarla(yeni_havuz: Array, yeni_kenar_basina_renk_sayisi: int):
	renk_havuzu = yeni_havuz.duplicate()
	kenar_basina_renk_sayisi = clampi(yeni_kenar_basina_renk_sayisi, 1, 3)
	_kenar_renklerini_karistir()

func _ready():
	_kenar_renklerini_karistir()

func _process(delta):
	if not firlatildi:
		position.y += speed * delta
	gecen_sure += delta
	if gecen_sure >= DONUS_SURESI:
		gecen_sure = 0.0
		rotation = wrapf(rotation + TAU / 3.0, 0.0, TAU)
		hedef_kenar = (hedef_kenar + 1) % 3
		_kenar_renklerini_karistir()

func eslesir_mi(secili_renk: String) -> bool:
	return renkli_kenarlar.size() == 3 and renkli_kenarlar[hedef_kenar].has(secili_renk)

func _kenar_renklerini_karistir():
	var secenekler = renk_havuzu.duplicate()
	secenekler.shuffle()
	renkli_kenarlar = []
	for kenar in range(3):
		var baslangic = kenar * kenar_basina_renk_sayisi
		renkli_kenarlar.append(secenekler.slice(baslangic, baslangic + kenar_basina_renk_sayisi))
	renk = renkli_kenarlar[hedef_kenar][0]
	queue_redraw()

func _draw():
	if renkli_kenarlar.size() != 3:
		return
	# Kenar uzunluğu 92 olan eşkenar üçgen: küçük sandık ölçüsüyle uyumludur.
	# Böylece her 120° dönüşte bir sonraki kenar tam yatay tabana gelir.
	var noktalar = [Vector2(0, -53.12), Vector2(-46, 26.56), Vector2(46, 26.56)]
	for kenar in range(3):
		_kenari_ciz(noktalar[kenar], noktalar[(kenar + 1) % 3], renkli_kenarlar[kenar])
	var baslangic: Vector2 = noktalar[hedef_kenar]
	var bitis: Vector2 = noktalar[(hedef_kenar + 1) % 3]
	draw_circle(baslangic.lerp(bitis, 0.5), 5.0, Color.WHITE)

func _kenari_ciz(baslangic: Vector2, bitis: Vector2, renkler: Array):
	for indeks in renkler.size():
		var parca_baslangici = baslangic.lerp(bitis, float(indeks) / renkler.size())
		var parca_bitisi = baslangic.lerp(bitis, float(indeks + 1) / renkler.size())
		draw_line(parca_baslangici, parca_bitisi, RENKLER[renkler[indeks]], KENAR_KALINLIGI, true)
