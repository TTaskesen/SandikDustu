extends Node

const REKOR_DOSYASI = "user://rekor.save"
const ILERLEME_DOSYASI = "user://sandik_dustu_ilerleme.json"
const SeviyeVeritabani = preload("res://scripts/seviye_veritabani.gd")
const DilYoneticisi = preload("res://scripts/dil_yoneticisi.gd")

signal dil_degisti(kod: String)

const BASARIMLAR = [
	{"id": "rekor_10", "metin": "achievement_start", "aciklama": "achievement_start_desc", "tur": "rekor", "hedef": 10},
	{"id": "seri_5", "metin": "achievement_master", "aciklama": "achievement_master_desc", "tur": "seri", "hedef": 5},
	{"id": "hatasiz", "metin": "achievement_flawless", "aciklama": "achievement_flawless_desc", "tur": "hatasiz", "hedef": 1},
	{"id": "toplam_50", "metin": "achievement_hunter", "aciklama": "achievement_hunter_desc", "tur": "toplam", "hedef": 50},
	{"id": "seviye_10", "metin": "achievement_journey", "aciklama": "achievement_journey_desc", "tur": "seviye", "hedef": 10},
]

const TEMALAR = [
	{"id": "klasik", "metin": "theme_classic", "fiyat": 0, "ust": Color("#24355c"), "alt": Color("#10182b")},
	{"id": "gece", "metin": "theme_night", "fiyat": 30, "ust": Color("#16213e"), "alt": Color("#090d1b")},
	{"id": "gunbatimi", "metin": "theme_sunset", "fiyat": 60, "ust": Color("#5d315f"), "alt": Color("#1b1634")},
]

# İleride Play Games/çevrimiçi liderlik tablosu eklenirse bu yerel istatistikler
# aktarım kaynağı olabilir; bu projede hiçbir çevrimiçi SDK veya hesap akışı yoktur.

var rekor: int = 0
var zorluk: String = "kolay"
var ilerleme: Dictionary = {}

func _ready():
	ilerlemeyi_yukle()

func _varsayilan_ilerleme() -> Dictionary:
	return {
		"surum": 1,
		"rekor": 0,
		"en_yuksek_seri": 0,
		"toplam_yakalanan": 0,
		"hatasiz_seviye_sayisi": 0,
		"tamamlanan_seviyeler": [],
		"acik_seviye": 1,
		"seviye_en_iyi": {},
		"basarimlar": {},
		"gunluk": {"tarih": "", "gorevler": []},
		"ogretici_tamamlandi": false,
		"kozmetik_para": 0,
		"acik_temalar": ["klasik"],
		"secili_tema": "klasik",
		"ayarlar": {"titresim": true, "dil": DilYoneticisi.VARSAYILAN_DIL},
	}

func rekoru_guncelle(skor: int) -> bool:
	if skor > rekor:
		rekor = skor
		ilerleme["rekor"] = rekor
		kaydet_ilerleme()
		return true
	return false

func rekoru_yukle():
	ilerlemeyi_yukle()

func rekoru_kaydet():
	ilerleme["rekor"] = rekor
	kaydet_ilerleme()

func ilerlemeyi_yukle():
	ilerleme = _varsayilan_ilerleme()
	if FileAccess.file_exists(ILERLEME_DOSYASI):
		var dosya = FileAccess.open(ILERLEME_DOSYASI, FileAccess.READ)
		if dosya:
			var json = JSON.new()
			if json.parse(dosya.get_as_text()) == OK and json.data is Dictionary:
				for anahtar in json.data:
					ilerleme[anahtar] = json.data[anahtar]
			dosya.close()
	elif FileAccess.file_exists(REKOR_DOSYASI):
		var eski_dosya = FileAccess.open(REKOR_DOSYASI, FileAccess.READ)
		if eski_dosya:
			ilerleme["rekor"] = int(eski_dosya.get_line())
			eski_dosya.close()
	_kayit_yapisini_duzelt()
	rekor = int(ilerleme.get("rekor", 0))
	_gunluk_gorevleri_yenile()
	kaydet_ilerleme()

func _kayit_yapisini_duzelt():
	var varsayilan = _varsayilan_ilerleme()
	for anahtar in varsayilan:
		if not ilerleme.has(anahtar):
			ilerleme[anahtar] = varsayilan[anahtar]
	if not ilerleme["ayarlar"] is Dictionary:
		ilerleme["ayarlar"] = varsayilan["ayarlar"]
	for ayar_anahtari in varsayilan["ayarlar"]:
		if not ilerleme["ayarlar"].has(ayar_anahtari):
			ilerleme["ayarlar"][ayar_anahtari] = varsayilan["ayarlar"][ayar_anahtari]
	if not ilerleme["gunluk"] is Dictionary:
		ilerleme["gunluk"] = varsayilan["gunluk"]

func kaydet_ilerleme() -> bool:
	var dosya = FileAccess.open(ILERLEME_DOSYASI, FileAccess.WRITE)
	if dosya == null:
		return false
	dosya.store_string(JSON.stringify(ilerleme))
	dosya.close()
	return true

func seviye_acik_mi(seviye_no: int) -> bool:
	return seviye_no >= 1 and seviye_no <= int(ilerleme.get("acik_seviye", 1))

func sonraki_acik_seviye() -> int:
	return clampi(int(ilerleme.get("acik_seviye", 1)), 1, SeviyeVeritabani.TOPLAM_SEVIYE)

func seviye_tamamla(seviye_no: int, skor: int, hatasiz: bool) -> Array:
	var tamamlanan: Array = ilerleme["tamamlanan_seviyeler"]
	if not tamamlanan.has(seviye_no):
		tamamlanan.append(seviye_no)
	var en_iyi: Dictionary = ilerleme["seviye_en_iyi"]
	var anahtar = str(seviye_no)
	en_iyi[anahtar] = maxi(int(en_iyi.get(anahtar, 0)), skor)
	ilerleme["acik_seviye"] = mini(SeviyeVeritabani.TOPLAM_SEVIYE, maxi(int(ilerleme["acik_seviye"]), seviye_no + 1))
	ilerleme["kozmetik_para"] = int(ilerleme["kozmetik_para"]) + int(SeviyeVeritabani.seviyeyi_al(seviye_no)["odul"])
	gunluk_ilerlet("seviye", 1)
	if hatasiz:
		ilerleme["hatasiz_seviye_sayisi"] = int(ilerleme["hatasiz_seviye_sayisi"]) + 1
	var yeni_basarimlar = basarimlari_guncelle()
	kaydet_ilerleme()
	return yeni_basarimlar

func sandik_yakalandi(seri: int):
	ilerleme["toplam_yakalanan"] = int(ilerleme["toplam_yakalanan"]) + 1
	ilerleme["en_yuksek_seri"] = maxi(int(ilerleme["en_yuksek_seri"]), seri)
	gunluk_ilerlet("yakala", 1)
	basarimlari_guncelle()
	kaydet_ilerleme()

func basarimlari_guncelle() -> Array:
	var acilanlar: Array = []
	var durum: Dictionary = ilerleme["basarimlar"]
	for basarim in BASARIMLAR:
		var id: String = basarim["id"]
		if durum.get(id, false):
			continue
		if _basarim_kosulu_saglandi(basarim):
			durum[id] = true
			acilanlar.append(basarim)
	return acilanlar

func _basarim_kosulu_saglandi(basarim: Dictionary) -> bool:
	match basarim["tur"]:
		"rekor": return rekor >= int(basarim["hedef"])
		"seri": return int(ilerleme["en_yuksek_seri"]) >= int(basarim["hedef"])
		"hatasiz": return int(ilerleme["hatasiz_seviye_sayisi"]) >= int(basarim["hedef"])
		"toplam": return int(ilerleme["toplam_yakalanan"]) >= int(basarim["hedef"])
		"seviye": return ilerleme["tamamlanan_seviyeler"].size() >= int(basarim["hedef"])
	return false

func _gunluk_gorevleri_yenile():
	var bugun = Time.get_date_string_from_system()
	var gunluk: Dictionary = ilerleme["gunluk"]
	if gunluk.get("tarih", "") == bugun and gunluk.get("gorevler", []) is Array and not gunluk["gorevler"].is_empty():
		return
	var sayi = abs(bugun.hash())
	gunluk["tarih"] = bugun
	gunluk["gorevler"] = [
		{"id": "yakala", "tur": "yakala", "metin": "daily_catch", "hedef": 20 + sayi % 11, "ilerleme": 0, "odul": 8, "tamamlandi": false},
		{"id": "hatasiz", "tur": "hatasiz_seri", "metin": "daily_streak", "hedef": 5 + sayi % 6, "ilerleme": 0, "odul": 10, "tamamlandi": false},
		{"id": "seviye", "tur": "seviye", "metin": "daily_level", "hedef": 1, "ilerleme": 0, "odul": 12, "tamamlandi": false},
	]

func gunluk_ilerlet(tur: String, miktar: int):
	_gunluk_gorevleri_yenile()
	var gunluk: Dictionary = ilerleme["gunluk"]
	for gorev in gunluk["gorevler"]:
		if gorev["tur"] != tur or gorev.get("tamamlandi", false):
			continue
		gorev["ilerleme"] = mini(int(gorev["hedef"]), int(gorev["ilerleme"]) + miktar)
		if int(gorev["ilerleme"]) >= int(gorev["hedef"]):
			gorev["tamamlandi"] = true
			ilerleme["kozmetik_para"] = int(ilerleme["kozmetik_para"]) + int(gorev["odul"])
	kaydet_ilerleme()

func gunluk_hatasiz_seri(seri: int):
	_gunluk_gorevleri_yenile()
	var gunluk: Dictionary = ilerleme["gunluk"]
	for gorev in gunluk["gorevler"]:
		if gorev["tur"] != "hatasiz_seri" or gorev.get("tamamlandi", false):
			continue
		gorev["ilerleme"] = maxi(int(gorev["ilerleme"]), seri)
		if int(gorev["ilerleme"]) >= int(gorev["hedef"]):
			gorev["tamamlandi"] = true
			ilerleme["kozmetik_para"] = int(ilerleme["kozmetik_para"]) + int(gorev["odul"])
	kaydet_ilerleme()

func ogretici_tamamlandi_mi() -> bool:
	return bool(ilerleme.get("ogretici_tamamlandi", false))

func ogreticiyi_tamamla():
	ilerleme["ogretici_tamamlandi"] = true
	kaydet_ilerleme()

func titresim_acik_mi() -> bool:
	return bool(ilerleme["ayarlar"].get("titresim", true))

func titresimi_degistir() -> bool:
	ilerleme["ayarlar"]["titresim"] = not titresim_acik_mi()
	kaydet_ilerleme()
	return titresim_acik_mi()

func dil_kodu() -> String:
	var kod := str(ilerleme.get("ayarlar", {}).get("dil", DilYoneticisi.VARSAYILAN_DIL))
	for dil in DilYoneticisi.DILLER:
		if dil["kod"] == kod:
			return kod
	return DilYoneticisi.VARSAYILAN_DIL

func dili_ayarla(kod: String):
	for dil in DilYoneticisi.DILLER:
		if dil["kod"] == kod:
			ilerleme["ayarlar"]["dil"] = kod
			kaydet_ilerleme()
			dil_degisti.emit(kod)
			return

func cevir(anahtar: String, degerler: Dictionary = {}) -> String:
	return DilYoneticisi.cevir(dil_kodu(), anahtar, degerler)

func rtl_mi() -> bool:
	return DilYoneticisi.rtl_mi(dil_kodu())

func basarim_adi(basarim: Dictionary) -> String:
	return cevir(str(basarim.get("metin", "")))

func basarim_aciklamasi(basarim: Dictionary) -> String:
	return cevir(str(basarim.get("aciklama", "")))

func tema_adi(tema: Dictionary) -> String:
	return cevir(str(tema.get("metin", "")))

func gunluk_gorev_metni(gorev: Dictionary) -> String:
	var anahtar := str(gorev.get("metin", ""))
	if not anahtar.begins_with("daily_"):
		match str(gorev.get("tur", "")):
			"yakala": anahtar = "daily_catch"
			"hatasiz_seri": anahtar = "daily_streak"
			"seviye": anahtar = "daily_level"
	return cevir(anahtar, {"target": int(gorev.get("hedef", 0))})

func yerel_verileri_sifirla() -> bool:
	# Bu işlem yalnızca oyuncunun uygulama içinden ikinci kez onaylamasıyla çağrılır.
	# Hesap, ağ hizmeti veya sunucuda tutulan veri bulunmadığından sıfırlama cihazdaki
	# oyun ilerlemesiyle sınırlıdır.
	ilerleme = _varsayilan_ilerleme()
	_gunluk_gorevleri_yenile()
	rekor = 0
	return kaydet_ilerleme()

func temalari_al() -> Array:
	return TEMALAR

func secili_tema() -> Dictionary:
	for tema in TEMALAR:
		if tema["id"] == ilerleme.get("secili_tema", "klasik"):
			return tema
	return TEMALAR[0]

func tema_al_veya_sec(tema_id: String) -> bool:
	for tema in TEMALAR:
		if tema["id"] != tema_id:
			continue
		var aciklar: Array = ilerleme["acik_temalar"]
		if not aciklar.has(tema_id):
			if int(ilerleme["kozmetik_para"]) < int(tema["fiyat"]):
				return false
			ilerleme["kozmetik_para"] = int(ilerleme["kozmetik_para"]) - int(tema["fiyat"])
			aciklar.append(tema_id)
		ilerleme["secili_tema"] = tema_id
		kaydet_ilerleme()
		return true
	return false
