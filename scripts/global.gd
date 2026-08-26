extends Node

const REKOR_DOSYASI = "user://rekor.save"

var rekor: int = 0
var zorluk: String = "kolay"

func _ready():
	rekoru_yukle()

func rekoru_guncelle(skor: int) -> bool:
	if skor > rekor:
		rekor = skor
		rekoru_kaydet()
		return true
	return false

func rekoru_yukle():
	if FileAccess.file_exists(REKOR_DOSYASI):
		var dosya = FileAccess.open(REKOR_DOSYASI, FileAccess.READ)
		rekor = int(dosya.get_line())
		dosya.close()

func rekoru_kaydet():
	var dosya = FileAccess.open(REKOR_DOSYASI, FileAccess.WRITE)
	dosya.store_string(str(rekor))
	dosya.close()
