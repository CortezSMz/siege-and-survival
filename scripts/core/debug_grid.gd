class_name DebugGrid extends Node2D

@export var minor_color : Color = Color(1, 1, 1, 0.08)
@export var major_color : Color = Color(1, 1, 1, 0.25)
@export var grid_size : float = GridUtils.TILE_SIZE
@export var major_every : float = 32.0

var _last_transform : Transform2D

func _ready() -> void:
	visible = UI_Handler.debug_grid_enabled
	z_index = 100
	_last_transform = Transform2D()

func _process(_delta: float) -> void:
	if not visible: return
	var current = get_canvas_transform()
	if current != _last_transform:
		_last_transform = current
		queue_redraw()

func _draw() -> void:
	var inverse = get_canvas_transform().affine_inverse()
	var viewport_size = get_viewport_rect().size
	var top_left = inverse * Vector2.ZERO
	var bottom_right = inverse * viewport_size

	var start_x = floor(top_left.x / grid_size) * grid_size
	var start_y = floor(top_left.y / grid_size) * grid_size
	var end_x = ceil(bottom_right.x / grid_size) * grid_size
	var end_y = ceil(bottom_right.y / grid_size) * grid_size

	var x = start_x
	while x <= end_x:
		var is_major = is_zero_approx(fmod(x, major_every))
		draw_line(Vector2(x, start_y), Vector2(x, end_y), major_color if is_major else minor_color, 1.0 if is_major else 0.5)
		x += grid_size

	var y = start_y
	while y <= end_y:
		var is_major = is_zero_approx(fmod(y, major_every))
		draw_line(Vector2(start_x, y), Vector2(end_x, y), major_color if is_major else minor_color, 1.0 if is_major else 0.5)
		y += grid_size
