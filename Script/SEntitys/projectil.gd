class_name Projectil
extends Area2D


@export var sprite: Sprite2D
var parent: Node2D

var direction: Vector2 = Vector2.ZERO
var damage: int = 2
var speed: float = 5.0


func _physics_process(_delta: float) -> void:
	position += direction * speed

func get_basics(new_parent: Node2D, new_direction: Vector2, new_damage: int = damage):
	parent = new_parent
	direction = new_direction.normalized() if not new_direction.is_normalized() else new_direction
	damage = new_damage

func set_new_image(new_image: Texture2D):
	sprite.texture = new_image

func _on_body_entered(body: Node2D) -> void:
	if body == parent: return
	if body is Soldier:
		body.damage(damage,self)
		queue_free()  

func _on_timer_timeout() -> void:
	queue_free()
