extends Line2D

func _ready():
	clear_points()
	add_point(Vector2(100, 100))
	add_point(Vector2(300, 150))
	width = 4
	default_color = Color(1, 0, 0)  # Rot
