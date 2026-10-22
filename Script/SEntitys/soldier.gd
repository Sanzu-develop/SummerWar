class_name Soldier
extends CharacterBody2D

signal killed
signal revived
signal atualize_life

## --- REFERÊNCIAS E CONFIGURAÇÕES ---
@export_group("Components")
@export var spawn_position: Vector2
@export var atributes_resource: SoldierResource
@export var atributes_resource_list: Array[SoldierResource]
@export var soldier_next: int = 1
@export var animated_sprite: AnimatedSprite2D
@export var effects_sprites: AnimatedSprite2D
@export var area: Area2D
@export var remote: RemoteTransform2D

@export_group("Control")
## -1: Controlado por IA / Outro sistema | 0: Player 1
@export var control_by: int = -1

## --- ESTADOS E VARIÁVEIS INTERNAS ---
var direction: Vector2 = Vector2.ZERO
var death: bool = false
var immunity: bool = true
var speed: float = 0.0

## --- MULTIPLAYER ---

var id: int = 1


# ==============================================================================
# CICLO DE VIDA (LIFECYCLE)
# ==============================================================================

func _enter_tree() -> void:
	set_multiplayer_authority(id)

func _ready() -> void:
	if atributes_resource:
		set_atribute_resource(atributes_resource)
	if atributes_resource_list.size() > 0: soldier_next = soldier_next % atributes_resource_list.size()
	
	play("idle")


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if death: 
		return

	_handle_input()
	_apply_movement(delta)
	_update_animations()


func _unhandled_input(event: InputEvent) -> void:
	if death or control_by == -1 or not is_multiplayer_authority(): 
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.shift_pressed and control_by == 1 or event.ctrl_pressed and control_by == 0 or event.keycode == KEY_TAB and not NetworkManager.is_multiplayer_active():
			pass_next_soldier_list()
			_update_attributes()
		
		if not is_playing("idle") and not is_playing("walk"): return
		
		if event.keycode == KEY_E and control_by == 0 or event.keycode == KEY_I and control_by == 1:
			var anim = "action2" if event.ctrl_pressed and control_by == 0 or event.shift_pressed  and control_by == 1 else "action1"
			play(anim)
		elif event.keycode == KEY_Q and control_by == 0 or event.keycode == KEY_P and control_by == 1:
			play("action3")


# ==============================================================================
# LÓGICA DE MOVIMENTO E INPUT
# ==============================================================================

func _handle_input() -> void:
	if not animated_sprite.is_playing(): play("idle")
	
	# Só captura input se o jogador estiver no controle e não estiver executando uma ação/ataque
	if control_by == 0:
		if is_playing("idle") or is_playing("walk"):
			direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		else:
			direction = Vector2.ZERO
	if control_by == 1:
		if is_playing("idle") or is_playing("walk"):
			direction = Input.get_vector("ui_left_2", "ui_right_2", "ui_up_2", "ui_down_2")
		else:
			direction = Vector2.ZERO

func _apply_movement(delta: float) -> void:
	velocity = velocity.move_toward(direction * speed, (10.0 * delta) * speed)
	
	# Espelha o sprite com base na direção X (mantém o último lado se parou)
	if direction.x != 0:
		animated_sprite.scale.x = sign(direction.x)
		
	move_and_slide()
	
	if is_multiplayer_active():
		send_server_atualize_basics(position,sign(animated_sprite.scale.x))


# ==============================================================================
# SISTEMA DE ATRIBUTOS E DANOS
# ==============================================================================

func set_atribute_resource(new_resource: SoldierResource) -> void:
	atributes_resource = new_resource.duplicate(true)
	_update_attributes()
	send_server_set_atributes(atributes_resource)


func _update_attributes() -> void:
	if atributes_resource:
		atributes_resource = atributes_resource.duplicate(true)
		speed = atributes_resource.get_speed()
		animated_sprite.offset = atributes_resource.offset
		if atributes_resource.animation:
			animated_sprite.sprite_frames = atributes_resource.animation
		atualize_life.emit()
		death = atributes_resource.is_dead()


func damage(count: int,attacking: Node2D) -> bool:
	if not is_multiplayer_authority(): return false
	if death:
		return false
	
	if not immunity:
		play("defense")
		if attacking is Soldier:
			attacking.play("dazed")
		return false
	
	play("damage")
	var is_dead = atributes_resource.damage(count)
	atualize_life.emit()
	
	if is_dead:
		death = true
		play("death")
		killed.emit()
	return true


func revive():
	if death:
		play("idle")
		atributes_resource.life.x = atributes_resource.life.y
		death = false
		position = spawn_position
		atualize_life.emit()
		revived.emit()


func pass_next_soldier_list():
	if atributes_resource_list.size() == 0: return
	if soldier_next < 0 or soldier_next >= atributes_resource_list.size(): soldier_next %= atributes_resource_list.size()
	if atributes_resource_list[soldier_next]: atributes_resource = atributes_resource_list[soldier_next]
	soldier_next = (soldier_next + 1) % atributes_resource_list.size()


# ==============================================================================
# SISTEMA DE ANIMAÇÕES E EVENTOS
# ==============================================================================

func play(animation_name: String) -> void:
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)
			if is_multiplayer_active() and is_multiplayer_authority():
				send_server_atualize_animation(animation_name)


func play_effect(animation_name: String) -> void:
	if effects_sprites.sprite_frames and effects_sprites.sprite_frames.has_animation(animation_name):
		if effects_sprites.animation != animation_name:
			effects_sprites.play(animation_name)


func is_playing(animation_name: String) -> bool:
	return animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name) and animated_sprite.animation == animation_name


func _update_animations() -> void:
	if direction != Vector2.ZERO:
		play("walk")
	elif is_playing("walk"):
		play("idle")


func _on_sprite_animation_finished() -> void:
	# Retorna para idle quando qualquer animação (ataque, dano, etc) termina, a menos que esteja morto
	if not death:
		play("idle")


func _on_sprite_frame_changed() -> void:
	if atributes_resource:
		atributes_resource.call_deferred("execute_action_key",self, animated_sprite.animation, animated_sprite.frame)


func _on_effect_animation_finished() -> void:
	play_effect("stop")


# ==============================================================================
# COLISÕES E ÁREAS
# ==============================================================================

func _on_area_body_entered(body: Node2D) -> void:
	if body == self or death: 
		return
		
	if body is Soldier or body is Tower:
		var strength = atributes_resource.get_strength()
		var atack_sucess = body.damage(strength,self)
		if atack_sucess: atributes_resource.call_deferred("execute_action_key",self,"attack",0)


# ==============================================================================
# MULTIPLAYER
# ==============================================================================


# Verificações
@rpc("any_peer","unreliable")
func send_server_atualize_basics(pos: Vector2,side: int):
	if NetworkManager.is_multiplayer_active() and multiplayer.is_server():
		atualize_basics.rpc(pos,side, multiplayer.get_remote_sender_id())

@rpc("any_peer","reliable")
func send_server_atualize_animation(new_animation: String):
	if NetworkManager.is_multiplayer_active() and multiplayer.is_server():
		atualize_animation.rpc(new_animation, multiplayer.get_remote_sender_id())

@rpc("any_peer","reliable")
func send_server_set_atributes(new_atribute: SoldierResource):
	if NetworkManager.is_multiplayer_active() and multiplayer.is_server():
		set_atributes.rpc(new_atribute, multiplayer.get_remote_sender_id())

@rpc("any_peer","reliable")
func send_server_execute_action(key_name: String, key_frame: int):
	if NetworkManager.is_multiplayer_active() and multiplayer.is_server():
		execute_action_rpc.rpc(key_name,key_frame, multiplayer.get_remote_sender_id())


# Atualizações
@rpc("authority","call_local","unreliable")
func atualize_basics(pos: Vector2,side: int,peer_id: int):
	if is_diferent_id(peer_id): 
		position = pos
		if side != 0: animated_sprite.scale.x = float(sign(side))

@rpc("authority","call_local","reliable")
func atualize_animation(new_animation: String, peer_id: int):
	if is_diferent_id(peer_id):
		play(new_animation)

@rpc("authority","call_local","reliable")
func set_atributes(new_atributes: SoldierResource, peer_id: int):
	if is_diferent_id(peer_id):
		set_atribute_resource(new_atributes)

@rpc("authority","call_local","reliable")
func execute_action_rpc(key_name: String, key_frame: int, peer_id: int):
	if is_diferent_id(peer_id):
		atributes_resource.execute_action_key(self,key_name,key_frame)


# Utilitarios
func is_diferent_id(peer_id: int) -> bool:
	if multiplayer.get_unique_id() != peer_id: return true
	return false

func is_multiplayer_active() -> bool:
	# Verifica se o peer existe e se o status dele é "Conectado"
	if multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		return true
	return false

func is_authority() -> bool:
	return is_multiplayer_authority()

func set_id(new_id: int):
	id = new_id
