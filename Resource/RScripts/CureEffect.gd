class_name CureEffect
extends ActionEffect


@export var heal_cure: int = 1

func execute(target: Soldier) -> void:
	if not target.effects_sprites: return
	
	target.effects_sprites.modulate = color
	target.play_effect(effect_name)
	
	target.atributes_resource.cure(heal_cure)
	target.atualize_life.emit()
