extends CharacterBody3D
class_name CarBase

@export_category("Configurações do Carro")
@export var velocidade_maxima: float = 8.0
@export var velocidade_re: float = 4.0
@export var aceleracao: float = 4.0
@export var frenagem: float = 5.0
@export var friccao: float = 2.0      
@export var velocidade_curva: float = 1.2

@export var camera_carro: Camera3D
@export var area_interacao: Area3D

@export_category("Configurações do Jogador")
@export var jogador: CharacterBody3D 

static var carro_em_uso: CarBase = null

var esta_dirigindo: bool = false
var jogador_na_area: bool = false
var velocidade_atual: float = 0.0

var gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camada_jogador_original: int = 0
var mascara_jogador_original: int = 0
var colisao_jogador_salva: bool = false
var ultimo_tempo_saida_ms: int = -1000
var tempo_bloqueio_entrada_ms: int = 600

func _ready() -> void:
	set_physics_process(false) 

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if esta_dirigindo:
			sair_do_carro()
		elif jogador_na_area and jogador != null:
			entrar_no_carro()

func _physics_process(delta: float) -> void:
	move(delta)
	
func move(delta):
	if not is_on_floor():
		velocity.y -= gravidade * delta
	else:
		velocity.y = 0

	var direction = Input.get_vector("move_right", "move_left", "move_back", "move_forward")

	if direction.y < 0:
		velocidade_atual = move_toward(velocidade_atual, velocidade_maxima, aceleracao * delta)
	elif direction.y > 0:
		velocidade_atual = move_toward(velocidade_atual, -velocidade_re, frenagem * delta)
	else: 
		velocidade_atual = move_toward(velocidade_atual, 0.0, friccao * delta)

	if abs(velocidade_atual) > 0.5:
		var sentido_curva = -1.0 if velocidade_atual > 0 else 1.0
		rotate_y(direction.x * velocidade_curva * delta * sentido_curva)

	var direcao_frente = -global_transform.basis.z
	
	velocity.x = direcao_frente.x * velocidade_atual
	velocity.z = direcao_frente.z * velocidade_atual

	move_and_slide()

func entrar_no_carro() -> void:
	if jogador == null:
		return
	if carro_em_uso != null and carro_em_uso != self:
		return
	if Time.get_ticks_msec() - ultimo_tempo_saida_ms < tempo_bloqueio_entrada_ms:
		return

	carro_em_uso = self
	esta_dirigindo = true
	set_physics_process(true) 

	if not colisao_jogador_salva:
		camada_jogador_original = jogador.collision_layer
		mascara_jogador_original = jogador.collision_mask
		colisao_jogador_salva = true

	jogador.collision_layer = 0
	jogador.collision_mask = 0
	jogador.visible = false
	jogador.process_mode = Node.PROCESS_MODE_DISABLED
	
	if camera_carro:
		camera_carro.make_current()

func sair_do_carro() -> void:
	if jogador == null:
		return

	ultimo_tempo_saida_ms = Time.get_ticks_msec()
	esta_dirigindo = false
	jogador_na_area = false
	set_physics_process(false) 
	velocidade_atual = 0.0 
	velocity = Vector3.ZERO
	carro_em_uso = null
	
	jogador.process_mode = Node.PROCESS_MODE_INHERIT
	jogador.visible = true
	if colisao_jogador_salva:
		jogador.collision_layer = camada_jogador_original
		jogador.collision_mask = mascara_jogador_original
	
	var posicao_saida: Vector3 = global_position + (global_transform.basis.x * 1.8) + Vector3.UP * 0.2
	jogador.global_position = posicao_saida
	jogador.global_rotation = global_rotation
	
	var camera_interna_jogador: Camera3D = obter_camera_jogador()
	
	if camera_interna_jogador:
		camera_interna_jogador.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if jogador == null and body.is_in_group("player"):
		jogador = body as CharacterBody3D
	
	if body == jogador:
		jogador_na_area = true
		if carro_em_uso == null and Time.get_ticks_msec() - ultimo_tempo_saida_ms >= tempo_bloqueio_entrada_ms:
			entrar_no_carro()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == jogador:
		jogador_na_area = false

func obter_camera_jogador() -> Camera3D:
	if jogador == null:
		return null

	var camera_direta: Camera3D = jogador.get_node_or_null("Camera3D") as Camera3D
	if camera_direta:
		return camera_direta

	return jogador.find_child("Camera3D", true, false) as Camera3D
