extends Node2D

@onready var hakkimizda_paneli: Panel = $HakkimizdaPaneli
@onready var hakkimizda_karartma: ColorRect = $HakkimizdaKarartma
@onready var hakkimizda_ekrani: Panel = $HakkimizdaEkrani

func _ready():
	_arkaplani_kur()

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
