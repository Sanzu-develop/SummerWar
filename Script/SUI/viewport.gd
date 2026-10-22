extends Control



@export var world: World
@export var blur: ColorRect


var tween: Tween


func add_blur():
	if tween and tween.is_running():
		tween.kill()
	
	tween.tween_property(blur,"modulate", Color(1.0, 1.0, 1.0, 1.0),1.0).set_trans(Tween.TRANS_CUBIC)

func remove_blur():
	if tween and tween.is_running():
		tween.kill()
	
	tween.tween_property(blur,"modulate", Color(1.0, 1.0, 1.0, 0.0),1.0).set_trans(Tween.TRANS_CUBIC)
