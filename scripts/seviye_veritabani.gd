extends RefCounted

const TOPLAM_SEVIYE := 50
const RENKLER := ["acik_yesil", "kirmizi", "mavi", "mor", "pembe", "sari", "turkuaz", "turuncu", "yesil"]
const KUCUK_SANDIK_OLUSTURMA_HIZ_CARPANI := 2.00

static func seviyeyi_al(seviye_no: int) -> Dictionary:
	var no = clampi(seviye_no, 1, TOPLAM_SEVIYE)
	var zorluk = _zorluk_belirle(no)
	var renk_sayisi = {"kolay": 3, "orta": 6, "zor": 9}[zorluk]
	# İlk tur çok kısa kalır; ardından hedefler küçük ama fark edilir adımlarla artar.
	# Böylece 50 seviye, aynı 3 sandığı tekrarlatan bir liste gibi hissettirmez.
	var hedef_skor = _hedef_skor_belirle(no)
	var dusme_hizi = _dusme_hizi_belirle(zorluk)
	var interval = _interval_belirle(no)
	var hata_toleransi = _hata_toleransi_belirle(no)
	return {
		"id": no,
		"ad": "%d. Seviye" % no,
		"zorluk": zorluk,
		"hedef_skor": hedef_skor,
		"dusme_hizi": dusme_hizi,
		"interval": interval,
		"renk_dizilimi": _renk_dizilimi(no, renk_sayisi),
		"hata_toleransi": hata_toleransi,
		"odul": 6 + int((no - 1) / 5.0) * 2,
	}

static func donen_seviyeyi_al(seviye_no: int) -> Dictionary:
	var no = clampi(seviye_no, 1, TOPLAM_SEVIYE)
	var zorluk = _zorluk_belirle(no)
	var renk_sayisi = {"kolay": 3, "orta": 6, "zor": 9}[zorluk]
	return {
		"id": no,
		"ad": "Dönen %d. Seviye" % no,
		"zorluk": zorluk,
		"hedef_skor": _hedef_skor_belirle(no),
		"dusme_hizi": _donen_dusme_hizi_belirle(zorluk),
		"interval": _donen_interval_belirle(no),
		"renk_havuzu": RENKLER.slice(0, renk_sayisi),
		"kenar_basina_renk_sayisi": {"kolay": 1, "orta": 2, "zor": 3}[zorluk],
		"renk_degisimi_suresi": _donen_renk_degisimi_suresi(zorluk),
		"hata_toleransi": _hata_toleransi_belirle(no),
		"odul": 6 + int((no - 1) / 5.0) * 2,
	}

static func ucgen_seviyeyi_al(seviye_no: int) -> Dictionary:
	var veri = donen_seviyeyi_al(seviye_no).duplicate(true)
	veri["ad"] = "Triangle %d" % clampi(seviye_no, 1, TOPLAM_SEVIYE)
	return veri

static func _zorluk_belirle(seviye_no: int) -> String:
	if seviye_no <= 15:
		return "kolay"
	if seviye_no <= 35:
		return "orta"
	return "zor"

static func _dusme_hizi_belirle(zorluk: String) -> int:
	# Hız piksel/saniye cinsindedir; tüm seviyeler kendi zorluk grubunun hızını kullanır.
	match zorluk:
		"kolay":
			return 200
		"orta":
			return 250
		"zor":
			return 300
	return 200

static func _donen_dusme_hizi_belirle(zorluk: String) -> int:
	match zorluk:
		"kolay":
			return 100
		"orta":
			return 150
		"zor":
			return 200
	return 100

static func _donen_renk_degisimi_suresi(zorluk: String) -> float:
	match zorluk:
		"kolay":
			return 2.0
		"orta":
			return 1.5
		"zor":
			return 1.0
	return 2.0

static func _donen_interval_belirle(seviye_no: int) -> float:
	if seviye_no <= 15:
		return maxf(1.1, 1.5 - (seviye_no - 1) * 0.025)
	if seviye_no <= 35:
		return maxf(0.82, 1.15 - (seviye_no - 16) * 0.017)
	return maxf(0.65, 0.88 - (seviye_no - 36) * 0.016)

static func _hedef_skor_belirle(seviye_no: int) -> int:
	if seviye_no == 1:
		return 3
	if seviye_no == 2:
		return 4
	if seviye_no == 3:
		return 5
	if seviye_no == 4:
		return 6
	if seviye_no <= 15:
		return mini(10, 6 + int((seviye_no - 4) / 2.0))
	if seviye_no <= 35:
		return mini(12, 7 + int((seviye_no - 16) / 3.0))
	return mini(13, 9 + int((seviye_no - 36) / 3.0))

static func _interval_belirle(seviye_no: int) -> float:
	var temel_interval: float
	if seviye_no <= 15:
		temel_interval = maxf(0.92, 1.16 - (seviye_no - 1) * 0.017)
	elif seviye_no <= 35:
		temel_interval = maxf(0.62, 0.90 - (seviye_no - 16) * 0.014)
	else:
		temel_interval = maxf(0.45, 0.62 - (seviye_no - 36) * 0.012)
	return temel_interval / KUCUK_SANDIK_OLUSTURMA_HIZ_CARPANI

static func _hata_toleransi_belirle(seviye_no: int) -> int:
	if seviye_no <= 11:
		return 2
	if seviye_no <= 25:
		return 1
	return 0

static func _renk_dizilimi(seviye_no: int, renk_sayisi: int) -> Array:
	var uygun_renkler: Array = RENKLER.slice(0, renk_sayisi)
	var kayma = (seviye_no - 1) % renk_sayisi
	var sonuc: Array = []
	for i in range(renk_sayisi):
		sonuc.append(uygun_renkler[(i + kayma) % renk_sayisi])
	return sonuc
