class_name Defense
extends Action


@export var active: bool = true

func execute(target: Soldier) -> void:
	if target.immunity != active: return
	target.immunity = !active
