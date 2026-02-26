extends Camera2D

# Zoom
@export var zoom_speed: float = 0.2
@export var min_zoom: float = 1.0
@export var max_zoom: float = 10.0
@export var zoom_smoothness: float = 10.0

# Pan movement
@export var map_limit_min: Vector2 = Vector2(0, 0)
@export var map_limit_max: Vector2 = Vector2(1152, 648)

var _target_zoom: float = 1.0
var _touch_points = {}
var _last_pinch_dist: float = 0.0

func _unhandled_input(event):
	# Mouse control
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = max(_target_zoom - zoom_speed, min_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = min(_target_zoom + zoom_speed, max_zoom)

	# Touch control
	# Track touches
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
			if _touch_points.size() < 2:
				_last_pinch_dist = 0.0

	# Track movement (drag and pinch)
	if event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		
		# 1 finger: PAN
		if _touch_points.size() == 1:
			global_position -= event.relative / zoom.x
			
		# 2 fingers: PINCH ZOOM
		elif _touch_points.size() == 2:
			var points = _touch_points.values()
			var current_dist = points[0].distance_to(points[1])
			
			if _last_pinch_dist > 0:
				var delta = current_dist - _last_pinch_dist
				_target_zoom = clamp(_target_zoom + (delta * 0.005 * _target_zoom), min_zoom, max_zoom)
			
			_last_pinch_dist = current_dist

func _process(delta):
	var focus_before_zoom = get_global_mouse_position()

	# Zoom smooth
	zoom.x = lerp(zoom.x, _target_zoom, delta * zoom_smoothness)
	zoom.y = zoom.x

	var focus_after_zoom = get_global_mouse_position()

	global_position += (focus_before_zoom - focus_after_zoom)

	# Camera position clamping
	var viewport_size = get_viewport_rect().size
	var visible_width = viewport_size.x / zoom.x
	var visible_height = viewport_size.y / zoom.y
	var max_x = map_limit_max.x - visible_width
	var max_y = map_limit_max.y - visible_height

	global_position.x = clamp(global_position.x, map_limit_min.x, max(map_limit_min.x, max_x))
	global_position.y = clamp(global_position.y, map_limit_min.y, max(map_limit_min.y, max_y))
