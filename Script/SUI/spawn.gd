class_name SpawnManager
extends Node2D


@export var world: World
@export var packed_player: PackedScene
@export var soldier_resource_list: Array[SoldierResource]


@rpc("authority","call_local","reliable")
func spawn_players():
	if NetworkManager.is_multiplayer_active():
		var peer_list_keys = NetworkManager.peers_configurate.keys()
		for key in peer_list_keys:
			var player = packed_player.instantiate() as Soldier
			if player:
				var configurate = NetworkManager.peers_configurate[key] as ConfiguratePeer
				for soldier_id in configurate.persons_selected_id: 
					player.atributes_resource_list.clear()
					player.atributes_resource_list.push_back(soldier_resource_list[soldier_id])
				
				player.set_atribute_resource(soldier_resource_list[configurate.persom_selected])
				player.set_id(configurate.peer_id)
				
				if configurate.peer_id == multiplayer.multiplayer_peer:
					player.control_by = 0
					if owner is World and owner.external_camera:
						var path = get_path_to(owner.external_camera)
						if path: player.remote.remote_path = path
				
				add_child(player)

func spawn_local(count: int = 1):
	if not NetworkManager.is_multiplayer_active():
		for id in range(count):
			var player = packed_player.instantiate() as Soldier
			if player:
				player.atributes_resource_list.clear()
				player.set_atribute_resource(soldier_resource_list[0 + id])
				
				player.control_by = 0 + id
				add_child(player)
				player.position.x += 200 * id
				
				if owner is World and owner.external_camera:
					var path = owner.external_camera.get_path() if id == 0 else owner.external_camera2.get_path()
					if path: 
						player.remote.remote_path = path
				
				world.players[id] = player
