extends CharacterBody3D

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

var esta_dirigindo: bool = false
var jogador_na_area: bool = false
var velocidade_atual: float = 0.0

var gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")

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
	esta_dirigindo = true
	set_physics_process(true) 
	
	jogador.visible = false
	jogador.process_mode = Node.PROCESS_MODE_DISABLED
	
	if camera_carro:
		camera_carro.make_current()

func sair_do_carro() -> void:
	esta_dirigindo = false
	set_physics_process(false) 
	velocidade_atual = 0.0 
	
	jogador.process_mode = Node.PROCESS_MODE_INHERIT
	jogador.visible = true
	
	jogador.global_position = global_position + (global_transform.basis.x * 0.5)
	
	var camera_interna_jogador = jogador.find_child("*Camera3D*", true, false) as Camera3D
	
	if camera_interna_jogador:
		camera_interna_jogador.make_current()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if jogador == null and body.is_in_group("player"):
		jogador = body as CharacterBody3D
	
	if body == jogador:
		jogador_na_area = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == jogador:
		jogador_na_area = false
