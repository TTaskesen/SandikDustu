extends RefCounted

const TOPLAM_SEVIYE := 50
const RENKLER := ["acik_yesil", "kirmizi", "mavi", "mor", "pembe", "sari", "turkuaz", "turuncu", "yesil"]

static func seviyeyi_al(seviye_no: int) -> Dictionary:
	var no = clampi(seviye_no, 1, TOPLAM_SEVIYE)
	var zorluk = _zorluk_belirle(no)
	var renk_sayisi = {"kolay": 3, "orta": 6, "zor": 9}[zorluk]
	var hedef_skor = mini(12, 3 + int((no - 1) / 4))
	var dusme_hizi = 95 + (no - 1) * 3
	var interval = maxf(0.42, 1.1 - (no - 1) * 0.012)
	var hata_toleransi = 2 if no <= 15 else (1 if no <= 35 else 0)
	return {
		"id": no,
		"ad": "%d. Seviye" % no,
		"zorluk": zorluk,
		"hedef_skor": hedef_skor,
		"dusme_hizi": dusme_hizi,
		"interval": interval,
		"renk_dizilimi": _renk_dizilimi(no, renk_sayisi),
		"hata_toleransi": hata_toleransi,
		"odul": 6 + int((no - 1) / 5) * 2,
	}

static func _zorluk_belirle(seviye_no: int) -> String:
	if seviye_no <= 15:
		return "kolay"
	if seviye_no <= 35:
		return "orta"
	return "zor"

static func _renk_dizilimi(seviye_no: int, renk_sayisi: int) -> Array:
	var uygun_renkler: Array = RENKLER.slice(0, renk_sayisi)
	var kayma = (seviye_no - 1) % renk_sayisi
	var sonuc: Array = []
	for i in range(renk_sayisi):
		sonuc.append(uygun_renkler[(i + kayma) % renk_sayisi])
	return sonuc
