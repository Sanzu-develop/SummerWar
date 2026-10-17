class_name SpawnDamage
extends Action


@export var spawn_entity: PackedScene


func execute(target: Soldier) -> void:
	var spawn_parent: Node2D
	if target.owner and target.owner is World:
		spawn_parent = target.owner.entitys
	elif target.owner:
		spawn_parent = target.owner
	
	if not spawn_parent and target: 
		spawn_parent = target.get_parent() as Node2D
	
	if not spawn_parent: 
		return
	
	var spawn = spawn_entity.instantiate() 
	
	if spawn is Projectil:
		var damage : int = target.atributes_resource.get_strength() / 2
		var direction: Vector2 = Vector2(target.animated_sprite.scale.x,0.0)
		spawn.global_position = target.global_position
		spawn.get_basics(target,direction,damage)
		spawn_parent.add_child(spawn)
