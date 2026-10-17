class_name SoldierResource
extends Resource


signal death

@export_group("Actions")
@export var actions: Dictionary[String, Dictionary]

@export_group("Visual")
@export var animation : SpriteFrames
@export_subgroup("LifeBar")
@export var background_color: Color = Color.DARK_RED
@export var life_color: Color = Color.DARK_GREEN

@export_group("Atributes")
@export var life: Vector2i = Vector2i(10,10)
@export var speed: Vector2 = Vector2(40.0,40.0)
@export var strength: Vector2i = Vector2i(4,4)
@export var strength_buffer: Vector2i = Vector2i(1,1)

@export_group("Align")
@export var offset: Vector2 = Vector2.ZERO


# Atributes

func get_speed() -> float:
	return speed.x

func get_max_speed() -> float:
	return speed.y

func get_life() -> int:
	return life.x

func get_max_life() -> int:
	return life.y

func get_strength() -> int:
	return strength.x * strength_buffer.x

func get_max_strength() -> int:
	return strength.y * strength_buffer.y

func get_offset() -> Vector2:
	return offset

func damage(count: int) -> bool:
	life.x = clamp(life.x - count, 0, life.x)
	if life.x == 0:
		death.emit()
		return true
	return false

func cure(count: int) -> bool:
	if life.x >= life.y: return false
	life.x = clamp(life.x + count, 0, life.y)
	return true

func is_dead() -> bool:
	if life.x == 0: return true
	return false


# Action
func execute_action_key(target: Soldier, key_name: String, key_frame: int):
	if not has_key_frame(key_name,key_frame): return
	if is_array_action(key_name,key_frame):
		for action in actions[key_name][key_frame]:
			if action is Action:
				action.execute(target)
				
				if target.is_multiplayer_active() and target.is_authority():
					target.send_server_execute_action(key_name,key_frame)
	else:
		var action = get_command(key_name, key_frame)
		if not action: return
		
		action.execute(target)
		
		if target.is_multiplayer_active() and target.is_authority():
			target.send_server_execute_action(key_name,key_frame)

func get_command(key_name: String, key_frame: int) -> Action:
	if has_key_frame(key_name,key_frame): return actions[key_name][key_frame] as Action
	return null

func is_array_action(key_name: String, key_frame: int) -> bool:
	if has_key_frame(key_name,key_frame):
		return actions[key_name][key_frame] is Array
	return false

func has_key_frame(key_name: String, key_frame: int) -> bool:
	return actions.has(key_name) and actions[key_name].has(key_frame)
