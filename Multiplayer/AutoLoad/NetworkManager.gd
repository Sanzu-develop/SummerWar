# NetworkManager.gd (Autoload)
extends Node

const DEFAULT_PORT = 7000
var peer = ENetMultiplayerPeer.new()

var peers_configurate: Dictionary[int, ConfiguratePeer]


func create_game(user_name: String, port: int = DEFAULT_PORT, max_players: int = 4):
	var error = peer.create_server(port, max_players)
	if error != OK:
		print("Erro ao criar servidor")
		return
	multiplayer.multiplayer_peer = peer
	
	var new_configurate := ConfiguratePeer.new()
	new_configurate.name = user_name
	new_configurate.peer_id = 1
	
	print("Servidor rodando!")

func join_game(user_name: String, ip: String, port: int = DEFAULT_PORT):
	var error = peer.create_client(ip, port)
	if error != OK:
		print("Erro ao conectar")
		return
	multiplayer.multiplayer_peer = peer
	
	var new_configurate := ConfiguratePeer.new()
	new_configurate.name = user_name
	new_configurate.peer_id = peer
	
	print("Conectando ao host...")

@rpc("any_peer","reliable")
func send_atualize_configurate(new_config: ConfiguratePeer):
	if multiplayer.is_server():
		atualize_player_configurate.rpc(new_config, multiplayer.get_remote_sender_id())

@rpc("authority","call_local","reliable")
func atualize_player_configurate(new_config: ConfiguratePeer, remote_id: int):
	peers_configurate[remote_id] = new_config

func get_configurate_player(peer_id: int) -> ConfiguratePeer:
	return peers_configurate[peer_id]

func is_multiplayer_active() -> bool:
	# Verifica se o peer existe e se o status dele é "Conectado"
	if multiplayer.multiplayer_peer and not multiplayer.multiplayer_peer is OfflineMultiplayerPeer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		return true
	return false
