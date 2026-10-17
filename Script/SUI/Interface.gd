extends Control


@export var subview1: SubViewport
@export var subview2: SubViewport
@export var world : World


func _ready() -> void:
	subview2.world_2d = subview1.world_2d
