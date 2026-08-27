extends Node2D

@onready var hakkimizda_paneli: Panel = $HakkimizdaPaneli
@onready var hakkimizda_karartma: ColorRect = $HakkimizdaKarartma
@onready var hakkimizda_ekrani: Panel = $HakkimizdaEkrani

func _ready():
	_arkaplani_kur()
	_baslangic_logosunu_kur()

func _arkaplani_kur():
	var arkaplan = TextureRect.new()
	arkaplan.position = Vector2.ZERO
	arkaplan.size = Vector2(576, 800)
	arkaplan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gradyan = Gradient.new()
	gradyan.set_color(0, Color("#24355c"))
	gradyan.set_color(1, Color("#10182b"))
	var doku = GradientTexture2D.new()
	doku.gradient = gradyan
	doku.fill_from = Vector2(0.5, 0)
	doku.fill_to = Vector2(0.5, 1)
	arkaplan.texture = doku
	add_child(arkaplan)
	move_child(arkaplan, 0)

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
