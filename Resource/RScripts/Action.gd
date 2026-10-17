class_name Action
extends Resource


@export var name: String
@export_enum("Stop","Usage","Damage","Spawn","Cure") var type: int = 0


func execute(target: Soldier) -> void:
	pass
