class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer

@export var aim_root: Node2D

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var is_attack_pressed: bool = false

var _shooting_fingers: Array[int] = []
var _latest_aim_screen_pos: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	var st := event as InputEventScreenTouch
	if st:
		# 排除正在操作摇杆的手指
		if st.index == VirtualKnob.active_finger_index:
			return

		# 记录或移除射击手指
		if st.pressed:
			if st.index not in _shooting_fingers:
				_shooting_fingers.append(st.index)
				_latest_aim_screen_pos = st.position
		else:
			_shooting_fingers.erase(st.index)
		return
		
	# 射击的手指在屏幕上滑动时，更新瞄准位置
	var sd := event as InputEventScreenDrag
	if sd and sd.index in _shooting_fingers:
		_latest_aim_screen_pos = sd.position

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		gather_input()

func gather_input() -> void:
	# 1. 移动向量获取
	movement_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 2. 射击状态判断
	var device_attack := Input.is_action_pressed("attack") and VirtualKnob.active_finger_index == -1
	var touch_attack := not _shooting_fingers.is_empty()
	is_attack_pressed = device_attack or touch_attack
	
	# 3. 瞄准方向计算
	if touch_attack:
		# 手机端射击：使用记录的触摸坐标转换为世界坐标
		var canvas_transform := get_viewport().get_canvas_transform()
		var world_pos := canvas_transform.affine_inverse() * _latest_aim_screen_pos
		
		if aim_root.global_position.distance_to(world_pos) > 1.0:
			aim_vector = aim_root.global_position.direction_to(world_pos)
			
	elif not DisplayServer.is_touchscreen_available() and VirtualKnob.active_finger_index == -1:
		# 桌面端且没有按摇杆：使用鼠标指针的位置
		var mouse_world_pos := aim_root.get_global_mouse_position()
		if aim_root.global_position.distance_to(mouse_world_pos) > 1.0:
			aim_vector = aim_root.global_position.direction_to(mouse_world_pos)
			
	else:
		# 手机端未射击（或桌面端按着摇杆）：保持上一次的瞄准方向
		# 如果你希望角色在不射击时默认面向移动方向，可以取消下面两行的注释：
		# if movement_vector.length_squared() > 0.01:
		# 	aim_vector = movement_vector.normalized()
		pass
