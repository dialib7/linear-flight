extends Node2D

#@export var label_font: Font  # Weise im Inspector deine Font zu
var dynamic_font : ResourceImporterDynamicFont

# Konfiguration
var origin := Vector2(300, 400)  # Ursprung in Pixeln
var pixelprox := 100.0           # Pixel pro 1 Einheit
var range := 10                  # Sichtbarer Bereich in Einheiten

#func _ready():
#	dynamic_font = ResourceImporterDynamicFont.new()
#	dynamic_font.font_data = load("res://712_serif.ttf")
	#$Label.add_font_override("font", dynamic_font)
	
func _draw():
	draw_axes()
	draw_grid()
	draw_labels()

func draw_axes():
	# X-Achse
	draw_line(
		Vector2(0, origin.y),
		Vector2(get_viewport_rect().size.x, origin.y),
		Color(1, 0, 0),
		2
	)
	# Y-Achse
	draw_line(
		Vector2(origin.x, 0),
		Vector2(origin.x, get_viewport_rect().size.y),
		Color(0, 0, 1),
		2
	)

func draw_grid():
	var width = get_viewport_rect().size.x
	var height = get_viewport_rect().size.y

	var x_steps = ceil(width / pixelprox)
	var y_steps = ceil(height / pixelprox)

	# Vertikale Linien (x)
	for i in range(-x_steps, x_steps + 1):
		var x_pos = origin.x + i * pixelprox
		#var is_whole = (i % 1 == 0)
		#var is_quarter = absf(i % 1) == 0.25 or absf(i % 1) == 0.75 or absf(i % 1) == 0.5

		var color = Color(0.7, 0.7, 0.7, 0.3)
		if i % 1 == 0:
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, height), color, 1)

		# Viertelschritte zeichnen
		for offset in [0.25, 0.5, 0.75]:
			var fx = x_pos + offset * pixelprox
			draw_line(Vector2(fx, 0), Vector2(fx, height), Color(0.8, 0.8, 0.8, 0.1), 1)

	# Horizontale Linien (y)
	for j in range(-y_steps, y_steps + 1):
		var y_pos = origin.y + j * pixelprox
		draw_line(Vector2(0, y_pos), Vector2(width, y_pos), Color(0.7, 0.7, 0.7, 0.3), 1)

		# Viertelschritte
		for offset in [0.25, 0.5, 0.75]:
			var fy = y_pos + offset * pixelprox
			draw_line(Vector2(0, fy), Vector2(width, fy), Color(0.8, 0.8, 0.8, 0.1), 1)

func draw_labels():
	#if dynamic_font == null:
	#	return  # Font wurde nicht gesetzt
	var default_font = ThemeDB.fallback_font
	
	for i in range(-range, range + 1):
		# Beschriftung auf der X-Achse (Y = 0)
		var x_pos = origin + Vector2(i * pixelprox, 5)
		
		draw_string(default_font, x_pos, str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 1))

		# Beschriftung auf der Y-Achse (X = 0)
		if i != 0:  # Optional: Ursprung nur einmal beschriften
			var y_pos = origin + Vector2(5, i * pixelprox)
			draw_string(default_font, y_pos, str(-i), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
