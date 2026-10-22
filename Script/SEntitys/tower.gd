class_name Tower
extends StaticBody2D


signal atualize_life

enum STATE { NEW, DAMAGED, BROKEN}

@export var sprite: Sprite2D
@export var state: int = STATE.NEW
@export var initial_frame: int = 0
@export var life : Vector2i = Vector2i(50,50)
@export var color_life: Color
@export var color_background: Color


func _ready() -> void:
	atualize_state()

func atualize_state():
	if life.x <= 0: state = STATE.BROKEN
	elif life.x >= life.y / 2: state = STATE.NEW
	else: state = STATE.DAMAGED
	sprite.frame = initial_frame + state

func damage(count: int, _attacking: Node2D) -> bool:
	if life.x <= 0: return false
	life.x = clamp(life.x - count,0 , life.y)
	atualize_state()
	atualize_life.emit()
	return true

func get_life() -> int:
	return life.x

func get_max_life() -> int:
	return life.y
