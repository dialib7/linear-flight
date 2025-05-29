extends Sprite2D

func _draw():
	# Kleiner roter Punkt in der Mitte (0,0 ist Mittelpunkt des Node2D)
	draw_circle(Vector2.ZERO, 4, Color.RED)

#func _ready():
#    update()  # Zeichnung auslösen
