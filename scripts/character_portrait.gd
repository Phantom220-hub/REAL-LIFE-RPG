extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(220, 250)
	queue_redraw()

func _draw() -> void:
	var center := size.x * 0.5
	var base_y := size.y
	# Soft circular backdrop
	draw_circle(Vector2(center, 112), 92, Color("#263b59"))
	draw_circle(Vector2(center, 112), 82, Color("#314d70"))
	# Shoulders and cloak
	draw_colored_polygon(PackedVector2Array([
		Vector2(center - 83, base_y), Vector2(center - 67, 187),
		Vector2(center - 35, 164), Vector2(center + 35, 164),
		Vector2(center + 67, 187), Vector2(center + 83, base_y)
	]), Color("#26364d"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(center - 45, 176), Vector2(center, 218),
		Vector2(center + 45, 176), Vector2(center + 62, base_y),
		Vector2(center - 62, base_y)
	]), Color("#b77b43"))
	# Neck and face
	draw_rect(Rect2(center - 17, 137, 34, 39), Color("#c98761"))
	draw_circle(Vector2(center, 105), 48, Color("#e2a47b"))
	# Hair
	draw_colored_polygon(PackedVector2Array([
		Vector2(center - 49, 100), Vector2(center - 44, 58),
		Vector2(center - 17, 42), Vector2(center + 20, 45),
		Vector2(center + 49, 75), Vector2(center + 39, 91),
		Vector2(center + 17, 75), Vector2(center - 7, 82),
		Vector2(center - 32, 72), Vector2(center - 37, 111)
	]), Color("#342b2c"))
	# Eyes, brows and nose
	draw_rect(Rect2(center - 27, 101, 15, 4), Color("#49302b"))
	draw_rect(Rect2(center + 12, 101, 15, 4), Color("#49302b"))
	draw_circle(Vector2(center - 19, 111), 3, Color("#263b59"))
	draw_circle(Vector2(center + 19, 111), 3, Color("#263b59"))
	draw_line(Vector2(center, 111), Vector2(center - 3, 124), Color("#b87558"), 2)
	draw_line(Vector2(center - 10, 137), Vector2(center + 10, 137), Color("#75453d"), 2)
	# Shoulder armor
	draw_circle(Vector2(center - 55, 193), 20, Color("#d5ad62"))
	draw_circle(Vector2(center + 55, 193), 20, Color("#d5ad62"))
	draw_circle(Vector2(center - 55, 193), 12, Color("#536b82"))
	draw_circle(Vector2(center + 55, 193), 12, Color("#536b82"))
	# Small golden chest emblem
	draw_colored_polygon(PackedVector2Array([
		Vector2(center, 190), Vector2(center + 10, 203),
		Vector2(center, 216), Vector2(center - 10, 203)
	]), Color("#f2c66d"))
