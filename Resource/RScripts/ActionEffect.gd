class_name ActionEffect
extends Action


@export_group("Effect")
@export var color: Color = Color.WHITE
@export_enum("stop","heal","shield_hit") var effect_name: String = "heal"


func execute(target: Soldier) -> void:
	if target.effects_sprites: target.effects_sprites.modulate = color
	target.play_effect(effect_name)
