class_name VirtualKnob
extends TouchScreenButton

const DRAG_RADIUS := 16.0

# 静态变量，记录当前摇杆被哪个手指占用 (-1代表没被占用)
static  var active_finger_index := -1

var finger_index := -1
var drag_offset: Vector2

@onready var rest_pos := global_position

func _input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	if st:
		if st.pressed and finger_index == -1:
			var global_pos := st.position * get_canvas_transform()
			var local_pos := global_pos * get_global_transform()
			var rect := Rect2(Vector2.ZERO, texture_normal.get_size())
			if rect.has_point(local_pos):
				# pressed
				finger_index = st.index
				active_finger_index = st.index # 记录当前手指
				drag_offset = global_pos - global_position
				get_viewport().set_input_as_handled()
		elif not st.pressed and st.index == finger_index:
			# released
			_release_all()
			finger_index = -1
			active_finger_index = -1
			global_position = rest_pos
			
			get_viewport().set_input_as_handled()
	
	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		# drag
		var wish_pos := sd.position * get_canvas_transform() - drag_offset
		var movement := (wish_pos - rest_pos).limit_length(DRAG_RADIUS)
		global_position = rest_pos + movement
		
		movement /= DRAG_RADIUS
		_apply_axis(movement)
		get_viewport().set_input_as_handled()


func _apply_axis(axis: Vector2) -> void:
	if axis.x > 0:
		Input.action_release("move_left")
		Input.action_press("move_right", axis.x)
	elif axis.x < 0:
		Input.action_release("move_right")
		Input.action_press("move_left", -axis.x)
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")

	if axis.y > 0:
		Input.action_release("move_up")
		Input.action_press("move_down", axis.y)
	elif axis.y < 0:
		Input.action_release("move_down")
		Input.action_press("move_up", -axis.y)
	else:
		Input.action_release("move_up")
		Input.action_release("move_down")

func _release_all() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")
