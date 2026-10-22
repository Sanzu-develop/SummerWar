class_name World
extends Node2D


@export var tilemaps: Node2D
@export var spawn: SpawnManager
@export var entitys: Node2D
@export var external_camera : Camera2D
@export var external_camera2 : Camera2D
@export var players: Dictionary[int, Soldier]


func _ready() -> void:
	if multiplayer.is_server() and NetworkManager.is_multiplayer_active():
		spawn.spawn_players.rpc()
	
	elif not NetworkManager.is_multiplayer_active():
		spawn.spawn_local()
