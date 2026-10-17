extends Control


@export var packed_interface: PackedScene

@export var spawn_interface: Control
@export var transition: ColorRect
var tween: Tween

func _on_history_pressed() -> void:
	if packed_interface:
		if transition:
			tween = create_tween()
			tween.tween_property(transition,"modulate", Color() , 1.0)
			
			await  tween.finished
		
		get_tree().change_scene_to_packed(packed_interface)
		#var interface = packed_interface.instantiate()
		#spawn_interface.add_child(interface)
