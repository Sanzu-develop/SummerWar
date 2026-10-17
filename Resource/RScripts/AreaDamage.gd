class_name AreaDamage
extends Action


@export_group("Custom")
@export var position: Vector2 = Vector2.ZERO
@export var buffer: int = 1
@export_group("Area")
@export var shape: Shape2D = CircleShape2D.new()

func execute(target: Soldier) -> void:
	if not target.area: return
	
	var collision = target.area.get_child(0) as CollisionShape2D
	if not collision: return
	
	collision.shape = shape
	
	target.atributes_resource.strength_buffer.x = buffer
	
	target.area.position = position
	target.area.set_deferred("monitoring",true)
