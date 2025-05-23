extends Node2D

@export var Flugzeug : CharacterBody2D
#@export var text : Label

var start = false 
var koordinaten : Label
var formel : Label
var ende : Label
var fluglinie : Line2D
var ursprung : Marker2D


var m : float = 0
var b : int = 0

func _ready(): 
	formel = get_node("formel")  # Pfad relativ zum Skript-Knoten
	formel.text = "m * x + b: -> " + str(m) + "* x + " + str(b)  
	koordinaten = $Flugzeug/Label
	fluglinie = $fluglinie
	ursprung = $Marker2D
	ende = $Ende
	ende.visible = false
	b = -(Flugzeug.position.y - ursprung.position.y)
	Flugzeug.position.y = -(b-ursprung.position.y)
	#clear_points()
	#add_point(Vector2(100, 100))
	#add_point(Vector2(300, 150))
	#width = 4
	#default_color = Color(1, 0, 0)  # Rot
	
func _process(delta):
	if Input.is_action_pressed("move_up"):
		b += 1;
		print("Pfeil nach oben gedrückt ↑ b =" + str(b))
	if Input.is_action_pressed("move_down"):
		b -= 1;
		print("Pfeil nach unten gedrückt ↓ b = " + str(b))
	if Input.is_action_pressed("move_right"):
		m -= 0.01;
		print("Pfeil nach oben gedrückt ↑ m =" + str(m))
	if Input.is_action_pressed("move_left"):
		m += 0.01;
		print("Pfeil nach unten gedrückt ↓ m = " + str(m))

	formel.text = "m * x + b: -> " + str(m) + "* x + " + str(b)  	

func _physics_process(delta: float) -> void:
	#velocity += get_gravity() * delta
	#print("delta ist " + str(delta))
	#Flugzeug.position.x += 10.0
	koordinaten.text = "x = " + str(Flugzeug.position.x) + "\n" + "y = " + str(Flugzeug.position.y)
	
	var yAnfang = -((-100 -ursprung.position.x) * m) + -(b-ursprung.position.y)
	var yFlugzeug = -((Flugzeug.position.x -ursprung.position.x) * m) + -(b-ursprung.position.y)
	var yEnde = -((1200 -ursprung.position.x) * m) + -(b-ursprung.position.y)
	
	#var startpunkt = Vector2(-100.0,5)
	fluglinie.set_point_position(0, Vector2(-100,yAnfang))
	fluglinie.set_point_position(1, Vector2(Flugzeug.position.x,yFlugzeug))
	fluglinie.set_point_position(2, Vector2(1200,yEnde))
	
	if !start:
		Flugzeug.position.y = -((Flugzeug.position.x -ursprung.position.x) * m) + -(b-ursprung.position.y)
	
	if start:
		Flugzeug.position.x += 1.0
		Flugzeug.position.y = -((Flugzeug.position.x -ursprung.position.x) * m) + -(b-ursprung.position.y)
		#Flugzeug.position.y += 5.0
	if Flugzeug.position.x > 1200:
		Flugzeug.position.x = ursprung.position.x
		Flugzeug.position.y = ursprung.position.y
		m = 0
		b = 0
		yAnfang = -((-100 -ursprung.position.x) * m) + -(b-ursprung.position.y)
		yFlugzeug = -((Flugzeug.position.x -ursprung.position.x) * m) + -(b-ursprung.position.y)
		yEnde = -((1200 -ursprung.position.x) * m) + -(b-ursprung.position.y)
		fluglinie.set_point_position(0, Vector2(-100,yAnfang))
		fluglinie.set_point_position(1, Vector2(ursprung.position.x,yFlugzeug))
		fluglinie.set_point_position(2, Vector2(1200,yEnde))
		ende.text = "Du hast \n gewonnen!!!"
		ende.visible = true
		start = false  
	
func _on_button_pressed() -> void:
	ende.visible = false
	start = !start
	print("test " + str(formel.get_total_character_count()) + "test " + str(start))

func _on_felsenfeld_area_entered(area: Area2D) -> void:
	if (area.name == "FlugzeugArea" && area.get_parent().name == "Flugzeug"):
		print("_on_felsenfeld_area_entered: Leider Verloren")

func _on_felsenfeld_body_entered(body: Node2D) -> void:
	if (body.name == "Flugzeug" && body.get_parent().name == "Node2D"):
		print("_on_felsenfeld_body_entered: Leider Verloren")
	start = !start
	Flugzeug.position.x = ursprung.position.x
	Flugzeug.position.y = ursprung.position.y
	ende.text = "Du hast \n leider \n verloren."
	ende.visible = true
	
