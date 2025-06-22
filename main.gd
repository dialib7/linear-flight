extends Node2D

@export var Flugzeug : CharacterBody2D
@export var KoordinatenSystem : Node2D

var end_screen_scene = preload("res://Szene/Endszene.tscn")
var end_screen_instance
var game_ended = false

# Konfiguration
var origin := Vector2(300, 400)    # Ursprung in Pixeln
var bereich := 20                  # Sichtbarer Bereich in Einheiten

var koordinaten : Label
var ersterpunkt : Label
var endpunkt : Label
var Formel : Label
var ende : Label
var aufgabe : Panel
var fluglinie : Line2D
var ursprung : Marker2D
var startButton : Button
var airport : Sprite2D

var coeff := [0.0,0.0,0.0,0.0,0.0]
var m : float = 0
var b : int = 0

var parameterzahl : int = 2
var currentLevel : int = 0
var FlugzeugStartPosition := Vector2(300,200)
var AndererErsterPunkt := Vector2(0,0)
var Aufgabe1Text : String
var skalierung := 60

var timer : float = 0.0
var start = false 
enum states {START, SET, GO} # init, start, reset
var state := states.START

func _initLevel(level: int):
	print("Level init called: Level " + str(level) + "; State = " + str(state) + " von " + str(states))
	ende.visible = false
	aufgabe.visible = true
	fluglinie.visible = false
	get_node("Wolke2").visible = false
	get_node("Nebelwolke").visible = false
	get_node("Control/CheckButton").button_pressed = false
	get_node("Control/Formelbereich/eingabe-a0").text = str(0.0)
	get_node("Control/Formelbereich/eingabe-a1").text = str(0.0)
	Formel.label_settings.outline_color = Color.BLACK
	Formel.label_settings.outline_size = 0
	get_node("Control/Formelbereich/label-a0").visible = true
	get_node("Control/Formelbereich/eingabe-a0").visible = true

	game_ended = false
	start = false
	get_node("Control/Button").text = "Start"

	var aufgabenstellung = get_node("Control/Panel")
	aufgabenstellung.global_position.x = 1000
	
	var style_hightlight = StyleBoxFlat.new()
	var style = StyleBoxFlat.new()
	style_hightlight.set_border_width_all(2)
	style.set_border_width_all(2)
	style_hightlight.bg_color = Color(0.2, 0.2, 0.2)  # Dunkelgrauer Hintergrund
	style.bg_color = Color(0.2, 0.2, 0.2)  # Dunkelgrauer Hintergrund
	style_hightlight.border_color = Color(1, 0, 0) 
	style.border_color = Color.GRAY
	
	# zurücksetzen von Werten vor den Leveln
	for i in range(0,6):
		# für alle level buttons
		if i == level:
			get_node("Control/LevelPanel/ButtonLevel" + str(level+1)).add_theme_stylebox_override("normal", style_hightlight)
		else:
			get_node("Control/LevelPanel/ButtonLevel" + str(i+1)).add_theme_stylebox_override("normal", style)
	
	# zweite Wolke verstecken
	var Wolke2 = get_node("Wolke2")
	Wolke2.position = Vector2(2600.0,2320.0)
	Wolke2.visible = false
	get_node("Airport/Endpunkt").visible = true
	
	if level == 0:
		#Flugzeugposition
		FlugzeugStartPosition = Vector2(_xtoPixel(0),_ytoPixel(2))
		AndererErsterPunkt = Vector2(0,0)
		#Flughafenposition
		get_node("Airport").position = Vector2(_xtoPixel(4),_ytoPixel(0))
		
		#Hindernisse 
		get_node("Wolke").position = Vector2(_xtoPixel(3),_ytoPixel(2.2))
		get_node("Stadt").position = Vector2(_xtoPixel(1.4),_ytoPixel(0.16))
		get_node("Control/Panel/Aufgabenstellung1").text = Aufgabe1Text
		
		if state == states.START:
			parameterzahl = 2
			coeff[0] = 2.0
			coeff[1] = 0.0
			coeff[2] = 0.0
		
	elif level == 1:
		FlugzeugStartPosition = Vector2(_xtoPixel(-1),_ytoPixel(2))
		AndererErsterPunkt = Vector2(_xtoPixel(0),_ytoPixel(1))
		print("FlugzeugStartPosition.x: " + str(FlugzeugStartPosition.x))
		print("FlugzeugStartPosition.y: " + str(FlugzeugStartPosition.y))
		get_node("Airport").position = Vector2(_xtoPixel(5),_ytoPixel(-0.5))
		get_node("Wolke").position = Vector2(_xtoPixel(3),_ytoPixel(2))
		get_node("Stadt").position = Vector2(_xtoPixel(1),_ytoPixel(-0.25))
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 2:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Erster Punkt EP(0|1)\nEndpunkt FH(5|-0.5)\n\n" 
		Aufgabe.text += "Suche die passenden Parameter für a und b einer linearen Funktion mit dem Prototypen:\n\n" 
		Aufgabe.text += "[font_size=24]f(x) = ax + b[/font_size]"
		
		if state == states.START:
			parameterzahl = 2
			coeff[0] = 2.0
			coeff[1] = 0.0
			coeff[2] = 0.0
	
	elif level == 10:
		FlugzeugStartPosition = Vector2(_xtoPixel(-1),_ytoPixel(-1))
		AndererErsterPunkt = Vector2(0,0)
		get_node("Airport").position = Vector2(_xtoPixel(3.5),_ytoPixel(3))
		get_node("Wolke").position = Vector2(342.0,184.0)
		get_node("Stadt").position = Vector2(440.0,434.0)
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 3:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Startpunkt EP(-1|-1)\nEndpunkt FH(3.5|3)\n\n" 
		Aufgabe.text += "Suche die passenden Parameter für a0 (y-Achsenabschnitt) und a1 (Steigung m) einer linearen Funktion mit dem Prototypen:\n\n" 
		Aufgabe.text += "[font_size=24]f(x) = a1x + a0[/font_size]"
		
		if state == states.START:
			parameterzahl = 2
			coeff[0] = 0.0
			coeff[1] = 1.0
		
		Wolke2.position = Vector2(600.0,320.0)
		Wolke2.visible = true
	
	elif level == 2:
		
		FlugzeugStartPosition = Vector2(_xtoPixel(0),_ytoPixel(4))
		AndererErsterPunkt = Vector2(_xtoPixel(2),_ytoPixel(6)) 
		get_node("Airport").position = Vector2(_xtoPixel(6),_ytoPixel(4))
		get_node("Wolke").position = Vector2(_xtoPixel(2.1),_ytoPixel(4))
		get_node("Stadt").position = Vector2(_xtoPixel(2.9),_ytoPixel(3))
		
		Wolke2.position = Vector2(_xtoPixel(4),_ytoPixel(3.8))
		Wolke2.visible = true
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 3:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Startpunkt FZ(0|4)\nErster Punkt EP(2|6)\nFlughafen FH(6|4)\n" 
		Aufgabe.text += "Suche die Parameter a, b und c für einen Parabel-Flug nach der Funktion:\n\n" 
		Aufgabe.text += "[font_size=24]f(x) = ax² + bx + c[/font_size]"
		
		if state == states.START:
			parameterzahl = 3
			coeff[0] = 4.0
			coeff[1] = 0.0
			coeff[2] = 0.0
		
	elif level == 3:
		get_node("Nebelwolke").visible = true
		FlugzeugStartPosition = Vector2(_xtoPixel(0),_ytoPixel(4))
		AndererErsterPunkt = Vector2(_xtoPixel(2),_ytoPixel(6)) 
		get_node("Airport").position = Vector2(_xtoPixel(6),_ytoPixel(-2))
		get_node("Airport/Endpunkt").visible = false
		get_node("Wolke").position = Vector2(_xtoPixel(2),_ytoPixel(3.8))
		get_node("Stadt").position = Vector2(_xtoPixel(2.4),_ytoPixel(.66))
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 4:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Startpunkt FZ(0|4)\nHochpunkt EP(2|6)\n\n" 
		Aufgabe.text += "Suche die Parameter a, b und c für einen Parabel-Flug nach der Funktion:\n\n" 
		Aufgabe.text += "[font_size=24]f(x) = ax² + bx + c[/font_size]"
		
		if state == states.START:
			parameterzahl = 3
			coeff[0] = 4.0
			coeff[1] = 0.0
			coeff[2] = 0.0
		
		Wolke2.position = Vector2(_xtoPixel(7),_ytoPixel(3))
		Wolke2.visible = true
	
	elif level == 4:
		FlugzeugStartPosition = Vector2(_xtoPixel(0),_ytoPixel(4))
		AndererErsterPunkt = Vector2(0,0)
		get_node("Airport").position = Vector2(_xtoPixel(10),_ytoPixel(3))
		get_node("Wolke").position = Vector2(_xtoPixel(3),_ytoPixel(5))
		get_node("Stadt").position = Vector2(_xtoPixel(2),_ytoPixel(1))
		Wolke2.position = Vector2(_xtoPixel(5),_ytoPixel(2.8))
		Wolke2.visible = true
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 5:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Startpunkt FZ(0|4)\nEndpunkt FH(10|3)\n\n" 
		Aufgabe.text += "Fliege mit der [b]Steigung von -1 im Startpunkt[/b] los damit du" 
		Aufgabe.text += " zwischen Wolken und Stadt durch kommst und den Flughafen triffst!"
		
		if state == states.START:
			parameterzahl = 3
			coeff[0] = 4.0
			coeff[1] = 0.0
			coeff[2] = 0.0
		
	elif level == 5:
		aufgabe.visible = true
		FlugzeugStartPosition = Vector2(_xtoPixel(0),_ytoPixel(3))
		AndererErsterPunkt = Vector2(_xtoPixel(5),_ytoPixel(3)) 
		get_node("Airport").position = Vector2(_xtoPixel(10),_ytoPixel(3))
		get_node("Airport/Endpunkt").visible = true
		get_node("Wolke").position = Vector2(_xtoPixel(2),_ytoPixel(3.5))
		get_node("Stadt").position = Vector2(_xtoPixel(4.5),_ytoPixel(1.5))
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 6:[/b][/font_size]\n"
		Aufgabe.text += "[font_size=14]Gegeben:\nStartpunkt FZ(0|3)\nEndpunkt FH(10|3)\nWendepunkt EP(5|3)\n" 
		Aufgabe.text += "\nFinde die Parameter einer Funktion 3. Grades, die durch die gegebenen Punkte geht.\n" 
		Aufgabe.text += "[font_size=14]Gesucht:\nf(x) = ax³ + bx² + cx + d[/font_size]"
		
		if state == states.START:
			parameterzahl = 4
			coeff[0] = 3.0
			coeff[1] = 0.0
			coeff[2] = 0.0
			coeff[2] = 0.0
		
		Wolke2.position = Vector2(_xtoPixel(8),_ytoPixel(3.5))
		Wolke2.visible = true

	
	# Flugzeug auf Startpunkt neu positionieren
	Flugzeug.position.x = FlugzeugStartPosition.x
	Flugzeug.position.y = FlugzeugStartPosition.y
	queue_redraw()
	
	# unsichtbar machen, aktuell nur mit maximal 3 Parametern
	for i in range(0, 4):
		get_node("Control/Formelbereich/label-a" + str(i)).visible = false
		get_node("Control/Formelbereich/eingabe-a" + str(i)).visible = false
		if i > 0: get_node("Control/Formelbereich/x-a" + str(i)).visible = false
	
	# nur die benötigten Sichtbar machen
	for i in range(0, parameterzahl):
		get_node("Control/Formelbereich/label-a" + str(i)).visible = true
		get_node("Control/Formelbereich/label-a" + str(i)).text = char(97 + (parameterzahl - 1 - i)) + " ="
		get_node("Control/Formelbereich/eingabe-a" + str(i)).visible = true
		get_node("Control/Formelbereich/eingabe-a" + str(i)).text = str(coeff[i])
		if i > 0: get_node("Control/Formelbereich/x-a" + str(i)).visible = true

func _ready(): 
	Formel = get_node("Control/Formel")
	Aufgabe1Text = get_node("Control/Panel/Aufgabenstellung1").text
	
	startButton = $Control/Button
	ersterpunkt = $StartPunkt
	endpunkt = $Airport/Endpunkt
	airport = $Airport
	koordinaten = $Flugzeug/FlugzeugPunkt
	fluglinie = $Fluglinie
	ursprung = $Ursprung
	ende = $Ende
	aufgabe = $Control/Panel
	
	_scaleObjects(get_node("Stadt"))
	_scaleObjects(get_node("Wolke"))
	_scaleObjects(get_node("Wolke2"))

	origin = ursprung.position
	state = states.START
	_initLevel(currentLevel)

func _scaleObjects(object: Node2D):
	object.scale.x = object.scale.x * skalierung/100;
	object.scale.y = object.scale.y * skalierung/100;

func _scaleObjectsFaktor(object: Node2D, faktor: float):
	object.scale.x = object.scale.x * faktor;
	object.scale.y = object.scale.y * faktor;
	
func _draw() -> void:
	if (AndererErsterPunkt.x != 0):
		ersterpunkt.text = "EP(" + str((_pixelToX(AndererErsterPunkt.x))) + "|" + str(_pixelToY(AndererErsterPunkt.y)) + ")"
		ersterpunkt.position = Vector2(AndererErsterPunkt.x-32,AndererErsterPunkt.y+20)
		draw_circle(Vector2(AndererErsterPunkt.x,AndererErsterPunkt.y), 10, Color.RED, true)
	else:
		var flugzeugX : float = _pixelToX(Flugzeug.position.x)
		var flugzeugY = _pixelToY(Flugzeug.position.y)
		ersterpunkt.text = "SP(" + str(flugzeugX) + "|" + str(flugzeugY).substr(0,4) + ")"
		ersterpunkt.position = Vector2(Flugzeug.position.x-32,Flugzeug.position.y+20)
		draw_circle(Vector2(Flugzeug.position.x,Flugzeug.position.y), 10, Color.RED, true)

	draw_circle(Vector2(airport.position.x,airport.position.y), 10, Color.RED, true)
	var flughafenX = (airport.position.x-ursprung.position.x)/skalierung
	var flughafenY = -(airport.position.y-ursprung.position.y)/skalierung	
	endpunkt.text = "FH(" + str(flughafenX) + "|" + str(flughafenY).substr(0,4) + ")"
	
	draw_axes()
	draw_grid()
	draw_labels()
	drawFunction()

func drawFunction():
	for i in range(-50,150,1):
		fluglinie.set_point_position(i+50, Vector2(_xtoPixel(i/10.0),_ytoPixel(_formelberechnen(i/10.0))))
	
func _process(delta):
	if timer > 0:
		timer -= delta
	else:
		$Control/StartpunktInfo.visible = false
	
	if Input.is_action_pressed("move_up"):
		b += 1;
		print("Pfeil nach oben gedrückt ↑ b =" + str(b))
	if Input.is_action_pressed("move_down"):
		b -= 1;
		print("Pfeil nach unten gedrückt ↓ b = " + str(b))
	if Input.is_action_pressed("move_right"):
		m -= 0.01;
		print("Pfeil nach rechts gedrückt -> m =" + str(m))
	if Input.is_action_pressed("move_left"):
		m += 0.01;
		print("Pfeil nach links gedrückt <- m = " + str(m))
		
func _physics_process(_delta: float) -> void:
	
	if parameterzahl == 2:
		Formel.text = "Aktuelle Formel:   f(x) = " + str(coeff[1]) + "x + " + str(coeff[0])
	elif parameterzahl == 3:
		Formel.text = "Aktuelle Formel:   f(x) = " + str(coeff[2]) + "x² + " + str(coeff[1]) + "x + " + str(coeff[0])
	elif parameterzahl == 4:
		Formel.text = "Aktuelle Formel:   f(x) = " + str(coeff[3]) + "x³ + " + str(coeff[2]) + "x² + " + str(coeff[1]) + "x + " + str(coeff[0])
	
	m = coeff[1]
	b = coeff[0]*skalierung
	
	# Koordinaten des Flugzeuges
	var flugzeugX = (Flugzeug.position.x-ursprung.position.x)/skalierung
	var flugzeugY = -(Flugzeug.position.y-ursprung.position.y)/skalierung
	koordinaten.text = "FZ(" + str(flugzeugX).substr(0,4) + "|" + str(flugzeugY).substr(0,4) + ")"
	
	if start:
		Flugzeug.position.x += 1.0
		Flugzeug.position.y = _ytoPixel(_formelberechnen(_pixelToX(Flugzeug.position.x)))

		if Flugzeug.position.x == airport.position.x:
			if Flugzeug.position.y == airport.position.y:
				get_node("Nebelwolke").visible = false
				_end("Du hast es\ngeschafft!!!")
				show_end_screen("Du hast gewonnen!")
				game_ended = true;
				start = false;
		if Flugzeug.position.x > airport.position.x + 50:
			_end("Du hast \n leider \n verloren.")
			game_ended = true;
			start = false;

func _on_area_2d_wolke_body_entered(body: Node2D) -> void:
	if (body.name == "Flugzeug" && body.get_parent().name == "Node2D" && start):
		print("_on_area_2d_2_area_shape_entered: Leider Verloren")
		_end("Du hast\nleider\nverloren.")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Flugzeug" && body.get_parent().name == "Node2D" && start):
		print("_on_area_d_2_area_shape_entered: Leider Verloren")
		_end("Du hast\nleider\nverloren.")

func _on_button_pressed() -> void:
	if state == states.START:
		print("Wert von _ytoPixel(_formelberechnen(_pixelToX(FlugzeugStartPosition.x))): " + str(_ytoPixel(_formelberechnen(_pixelToX(FlugzeugStartPosition.x)))))
		print("Wert von FlugzeugStartPosition.y: " + str(FlugzeugStartPosition.y))
		# check ob die StartPosition des Flugzeuges mit dem richtigen StartPunkt übereinstimmt
		if abs(FlugzeugStartPosition.y - _ytoPixel(_formelberechnen(_pixelToX(FlugzeugStartPosition.x)))) < 2 || AndererErsterPunkt.x != 0:
			start = true
			state = states.GO
			get_node("Control/Button").text = "Stop"
		else:
			print("Das geht doch nicht!")
			timer = 3
			$Control/StartpunktInfo.visible = true
			var tween = get_tree().create_tween()
			tween.tween_property(startButton, "modulate", Color(1, 0.5, 0.5), 0.2)
			tween.tween_property(startButton, "modulate", Color(1, 1, 1), 0.2)
			
	elif state == states.GO:
		state = states.SET
		start = false
		get_node("Control/Button").text = "Reset"
	elif state == states.SET:
		_initLevel(currentLevel)
		state = states.START
		get_node("Control/Button").text = "Start"

func _end(text: String):
	start = false
	state = states.SET
	get_node("Control/Button").text = "Reset"
	ende.text = text
	
	if text.contains("gewonnen"):
		Formel.label_settings.outline_color = Color.GREEN
		Formel.label_settings.outline_size = 5
		Formel.label_settings.font_size = 24
		var tween := Formel.create_tween()
		tween.tween_property(Formel, "rotation_degrees", 360, 1.0)
	else:
		ende.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		#ende.modulate = Color.FIREBRICK
	
	ende.visible = true
	aufgabe.visible = false

func show_end_screen(message: String):
	end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.show_message(message)
	
func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fluglinie.visible = true
	else:
		fluglinie.visible = false
	print("hilfslinie = " + str(toggled_on))

func _on_line_edit_text_changed(new_text: String) -> void:
	coeff[0] = new_text.to_float()
	drawFunction()
	Flugzeug.position.y = _ytoPixel(_formelberechnen(_pixelToX(Flugzeug.position.x)))
	
func _on_line_edit_2_text_changed(new_text: String) -> void:
	coeff[1] = new_text.to_float()
	drawFunction()
	Flugzeug.position.y = _ytoPixel(_formelberechnen(_pixelToX(Flugzeug.position.x)))

func _on_line_edit_3_text_changed(new_text: String) -> void:
	coeff[2] = new_text.to_float()
	drawFunction()
	Flugzeug.position.y = _ytoPixel(_formelberechnen(_pixelToX(Flugzeug.position.x)))

func _on_line_edit_4_text_changed(new_text: String) -> void:
	coeff[3] = new_text.to_float()
	drawFunction()
	Flugzeug.position.y = _ytoPixel(_formelberechnen(_pixelToX(Flugzeug.position.x)))

func _on_button_level_1_pressed() -> void:
	currentLevel = 0
	state = states.START
	_initLevel(currentLevel)

func _on_button_level_2_pressed() -> void:
	currentLevel = 1
	state = states.START
	_initLevel(currentLevel)
	
func _on_button_level_3_pressed() -> void:
	currentLevel = 2
	state = states.START
	_initLevel(currentLevel)

func _on_button_level_4_pressed() -> void:
	currentLevel = 3
	state = states.START
	_initLevel(currentLevel)
	
func _on_button_level_5_pressed() -> void:
	currentLevel = 4
	state = states.START
	_initLevel(currentLevel)

func _on_button_level_6_pressed() -> void:
	currentLevel = 5
	state = states.START
	_initLevel(currentLevel)

func _formelberechnen(xWert: float) -> float:
	var yWert = 0
	yWert = coeff[4]*pow(xWert,4) + coeff[3]*pow(xWert,3) + coeff[2]*pow(xWert,2) + coeff[1]*xWert + coeff[0]
	return yWert
	
func _xtoPixel(xWert: float) -> int:
	return int((xWert * skalierung) + ursprung.position.x)
	
func _pixelToX(xPixel: float) -> float:
	return (xPixel - ursprung.position.x)/skalierung

func _pixelToY(yPixel: float) -> float:
	return -(yPixel-ursprung.position.y)/skalierung

func _ytoPixel(yWert: float) -> int:
	return int(-(yWert*skalierung-ursprung.position.y))

################################## KOORDINATENSYSTEM ######################################################

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

	var x_steps = ceil(width / skalierung)
	var y_steps = ceil(height / skalierung)

	# Vertikale Linien (x)
	for i in range(-x_steps, x_steps + 1):
		var x_pos = origin.x + i * skalierung
		#var is_whole = (i % 1 == 0)
		#var is_quarter = absf(i % 1) == 0.25 or absf(i % 1) == 0.75 or absf(i % 1) == 0.5

		var color = Color(0.7, 0.7, 0.7, 0.3)
		if i % 1 == 0:
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, height), color, 1)

		# Viertelschritte zeichnen
		for offset in [0.25, 0.5, 0.75]:
			var fx = x_pos + offset * skalierung
			draw_line(Vector2(fx, 0), Vector2(fx, height), Color(0.8, 0.8, 0.8, 0.1), 1)

	# Horizontale Linien (y)
	for j in range(-y_steps, y_steps + 1):
		var y_pos = origin.y + j * skalierung
		draw_line(Vector2(0, y_pos), Vector2(width, y_pos), Color(0.7, 0.7, 0.7, 0.3), 1)

		# Viertelschritte
		for offset in [0.25, 0.5, 0.75]:
			var fy = y_pos + offset * skalierung
			draw_line(Vector2(0, fy), Vector2(width, fy), Color(0.8, 0.8, 0.8, 0.1), 1)

func draw_labels():
	#if dynamic_font == null:
	#	return  # Font wurde nicht gesetzt
	var default_font = ThemeDB.fallback_font
	
	for i in range(-bereich, bereich + 1):
		# Beschriftung auf der X-Achse (Y = 0)
		var x_pos = origin + Vector2(i * skalierung, 5)
		
		draw_string(default_font, x_pos, str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 1))
		# Beschriftung auf der Y-Achse (X = 0)
		if i != 0:  # Optional: Ursprung nur einmal beschriften
			var y_pos = origin + Vector2(5, i * skalierung)
			draw_string(default_font, y_pos, str(-i), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _on_link_zu_wa_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta) # Replace with function body.
