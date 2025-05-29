extends Node2D

@export var Flugzeug : CharacterBody2D
@export var KoordinatenSystem : Node2D

var koordinaten : Label
var startpunkt : Label
var endpunkt : Label
var Formel : Label
var ende : Label
var aufgabe : Panel
var fluglinie : Line2D
var ursprung : Marker2D
var startButton : Button
var airport : Sprite2D

var coeff := [2.0,0.0,0.0,0.0,0.0]
var m : float = 0
var b : int = 0

var parameterzahl : int = 2
var currentLevel : int = 0
var FlugzeugStartPosition := Vector2(300,200)
var Aufgabe1Text : String
var skalierung := 100

var timer : float = 0.0
var start = false 
enum states {START, SET, GO}
var state := states.START

func _initLevel(level: int):
	print("Level init called")
	ende.visible = false
	aufgabe.visible = true
	fluglinie.visible = false
	get_node("Wolke2").visible = false
	get_node("Control/CheckButton").button_pressed = false
	get_node("Control/LineEdit").text = str(0.0)
	get_node("Control/LineEdit2").text = str(0.0)
	Formel.label_settings.outline_color = Color.BLACK
	Formel.label_settings.outline_size = 0
	get_node("Control/Label").visible = true
	get_node("Control/LineEdit").visible = true
	start = false
	state = states.START
	get_node("Control/Button").text = "Start"
	
	var aufgabenstellung = get_node("Control/Panel")
	aufgabenstellung.global_position.x = 800
	
	if level == 0:
		#Flugzeugposition
		FlugzeugStartPosition = Vector2(300,200)
		#Flughafenposition
		get_node("Airport").position = Vector2(4*skalierung+ursprung.position.x,-(0-ursprung.position.y))
		
		#Hindernisse 
		get_node("Wolke").position = Vector2(592.0,184.0)
		get_node("Stadt").position = Vector2(440.0,384.0)
		get_node("Control/Panel/Aufgabenstellung1").text = Aufgabe1Text
		
		#initialisiere Gleichung/Formel
		Formel.text = "Aktuelle Formel:\nf(x) = " + str(coeff[1]) + "x + " + str(coeff[0])
		
		parameterzahl = 2
		coeff[0] = 2.0
		coeff[1] = 0.0
		
	elif level == 1:
		FlugzeugStartPosition = Vector2(-1*skalierung+ursprung.position.x,(1*skalierung+ursprung.position.y))
		get_node("Airport").position = Vector2(_xtoPixel(3.5),_ytoPixel(3))
		get_node("Wolke").position = Vector2(342.0,184.0)
		get_node("Stadt").position = Vector2(440.0,434.0)
		
		var Aufgabe = get_node("Control/Panel/Aufgabenstellung1")
		Aufgabe.text = "[font_size=20][b]Aufgabenstellung 2:[/b][/font_size]\n\n"
		Aufgabe.text += "[font_size=14]Startpunkt FZ(-1|-1)\nEndpunkt FZ(4|3)\n\n" 
		Aufgabe.text += "Suche die passenden Parameter für a0 (y-Achsenabschnitt) und a1 (Steigung m) einer linearen Funktion mit dem Prototypen:\n\n" 
		Aufgabe.text += "[font_size=24]f(x) = a1x + a0[/font_size]"
		
		parameterzahl = 2
		coeff[0] = 0.0
		coeff[1] = 1.0
		
		var Wolke2 = get_node("Wolke2")
		Wolke2.position = Vector2(600.0,320.0)
		Wolke2.visible = true
		
		Formel.text = "Aktuelle Formel:\nf(x) = " + str(coeff[1]) + "x + " + str(coeff[0])
		
	elif level == 2:
		get_node("Control/LineEdit").text = str(0.0)
		get_node("Control/LineEdit2").text = str(0.0)
		
	get_node("Control/LineEdit").text = str(coeff[0])
	get_node("Control/LineEdit2").text = str(coeff[1])
	Flugzeug.position.x = FlugzeugStartPosition.x
	Flugzeug.position.y = FlugzeugStartPosition.y
	
	queue_redraw()
	
	for i in range(1, parameterzahl):
		get_node("Control/Label" + str(i+1)).visible = true
		get_node("Control/LineEdit" + str(i+1)).visible = true

func _ready(): 
	Formel = get_node("Control/Formel")
	Aufgabe1Text = get_node("Control/Panel/Aufgabenstellung1").text
	
	startButton = $Control/Button
	startpunkt = $StartPunkt
	endpunkt = $Airport/Endpunkt
	airport = $Airport
	koordinaten = $Flugzeug/FlugzeugPunkt
	fluglinie = $Fluglinie
	ursprung = $Ursprung
	ende = $Ende
	aufgabe = $Control/Panel
	
	_initLevel(currentLevel)
	
func _draw() -> void:
	draw_circle(Vector2(Flugzeug.position.x,Flugzeug.position.y), 10, Color.RED, true)
	draw_circle(Vector2(airport.position.x,airport.position.y), 10, Color.RED, true)
	var flugzeugX = (Flugzeug.position.x-ursprung.position.x)/skalierung
	var flugzeugY = -(Flugzeug.position.y-ursprung.position.y)/skalierung
	startpunkt.text = "FZ(" + str(flugzeugX) + "|" + str(flugzeugY).substr(0,4) + ")"
	startpunkt.position = Vector2(Flugzeug.position.x-32,Flugzeug.position.y-40)
	var flughafenX = (airport.position.x-ursprung.position.x)/skalierung
	var flughafenY = -(airport.position.y-ursprung.position.y)/skalierung	
	endpunkt.text = "FH(" + str(flughafenX) + "|" + str(flughafenY).substr(0,4) + ")"

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
	Formel.text = "Aktuelle Formel:\nf(x) = " + str(coeff[1]) + "x + " + str(coeff[0])
	m = coeff[1]
	b = coeff[0]*skalierung
	
	# formel für die Berechnung der Geraden
	var yAnfang = -((-100 -ursprung.position.x) * m) + -(b-ursprung.position.y)
	var yFlugzeug = -((Flugzeug.position.x -ursprung.position.x) * m) + -(b-ursprung.position.y)
	var yEnde = -((1200 -ursprung.position.x) * m) + -(b-ursprung.position.y)
	fluglinie.set_point_position(0, Vector2(-100,yAnfang))
	fluglinie.set_point_position(1, Vector2(Flugzeug.position.x,yFlugzeug))
	fluglinie.set_point_position(2, Vector2(1200,yEnde))
	
	var flugzeugX = (Flugzeug.position.x-ursprung.position.x)/skalierung
	var flugzeugY = -(Flugzeug.position.y-ursprung.position.y)/skalierung
	koordinaten.text = "FZ(" + str(flugzeugX) + "|" + str(flugzeugY).substr(0,4) + ")"
	
	if start:
		Flugzeug.position.x += 1.0
		Flugzeug.position.y = -((Flugzeug.position.x - ursprung.position.x) * m) + -(b-ursprung.position.y)
		#Flugzeug.position.y += 5.0
	
	if Flugzeug.position.x == airport.position.x:
		if roundf(Flugzeug.position.y) == roundf(airport.position.y):
			_end("Du hast\ngewonnen!!!")
	if Flugzeug.position.x > airport.position.x + 50:
		_end("Du hast \n leider \n verloren.")

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
		if abs(FlugzeugStartPosition.y - _ytoPixel(_formelberechnen(_pixelToX(FlugzeugStartPosition.x)))) < 2:
			start = true
			state = states.GO
			get_node("Control/Button").text = "Stop"
		else:
			print("Das geht doch nicht!")
			timer = 5
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
		print(text)
		ende.label_settings.font_color = Color.WEB_GREEN # funktioniert nicht mit den Farben wie gedacht???
		ende.label_settings.outline_color = Color.GREEN
		Formel.label_settings.outline_color = Color.GREEN
		Formel.label_settings.outline_size = 5
		Formel.label_settings.font_size = 30
		Formel.text = "Sieger-Formel:\nf(x) = " + str(coeff[1]) + "x + " + str(coeff[0])
		
		var tween := Formel.create_tween()
		tween.tween_property(Formel, "rotation_degrees", 360, 1.0)
	else:
		ende.modulate = Color.FIREBRICK
	ende.visible = true
	aufgabe.visible = false
	
func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fluglinie.visible = true
	else:
		fluglinie.visible = false
	print("hilfslinie = " + str(toggled_on))

func _on_line_edit_text_changed(new_text: String) -> void:
	coeff[0] = new_text.to_float()
	if (Flugzeug.position.x == ursprung.position.x):
		Flugzeug.position.y = _ytoPixel(coeff[0])#-(coeff[0]*skalierung-ursprung.position.y)

func _on_line_edit_2_text_changed(new_text: String) -> void:
	coeff[1] = new_text.to_float()

func _on_line_edit_3_text_changed(new_text: String) -> void:
	coeff[1] = new_text.to_float()

func _on_line_edit_4_text_changed(new_text: String) -> void:
	coeff[3] = new_text.to_float()

func _on_line_edit_5_text_changed(new_text: String) -> void:
	coeff[4] = new_text.to_float()

func _on_button_level_1_pressed() -> void:
	currentLevel = 0
	_initLevel(currentLevel)

func _on_button_level_2_pressed() -> void:
	currentLevel = 1
	_initLevel(currentLevel)

func _formelberechnen(xWert: float) -> float:
	var yWert = 0
	yWert = coeff[4]*pow(xWert,4) + coeff[3]*pow(xWert,3) + coeff[2]*pow(xWert,2) + coeff[1]*xWert + coeff[0]
	return yWert
	
func _xtoPixel(xWert: float) -> int:
	return roundf(xWert * skalierung) + ursprung.position.x
	
func _pixelToX(xPixel: int) -> float:
	return (xPixel - ursprung.position.x)/100

func _pixelToY(yPixel: int) -> float:
	return -(yPixel-ursprung.position.y)/skalierung

func _ytoPixel(yWert: float) -> int:
	return -(yWert*skalierung-ursprung.position.y)
