class_name StopArea
extends Action


func execute(target: Soldier) -> void:
	if not target.area: return
	if target.area.monitoring: target.area.set_deferred("monitoring",false)
	target.atributes_resource.strength_buffer.x = target.atributes_resource.strength_buffer.y
