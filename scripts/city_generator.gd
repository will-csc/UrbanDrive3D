extends Node3D

var predios: Array[PackedScene] = [
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_A.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_B.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_C.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_D.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_E.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_F.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_G.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_H.gltf")
]

var decoracoes: Array[PackedScene] = [
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/bench.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/bush.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/dumpster.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/firehydrant.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/trash_A.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/trash_B.gltf")
]

var estrada_reta: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/road_straight.gltf")
var estrada_cruzamento: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/road_junction.gltf")
var estrada_faixa: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/road_straight_crossing.gltf")
var semaforo: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/trafficlight_A.gltf")
var poste: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/streetlight.gltf")
var caixa_agua: PackedScene = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/watertower.gltf")

@export var tamanho_cidade: int = 40
@export var profundidade_cidade: int = 24
@export var passo_rua: int = 2
@export var espacamento_predios: int = 4
@export var chance_decoracao: float = 0.35
@export var ruas_horizontais: Array[int] = [-8, 0, 8]
@export var ruas_verticais: Array[int] = [0, 12, 24, 36]

func _ready() -> void:
	randomize()
	limpar_geracao()
	gerar_malha_viaria()
	gerar_predios()
	gerar_mobiliario_urbano()
	gerar_ponto_marcante()

func limpar_geracao() -> void:
	for child in get_children():
		child.queue_free()

func gerar_malha_viaria() -> void:
	var metade_profundidade: int = profundidade_cidade / 2

	for x in range(0, tamanho_cidade + passo_rua, passo_rua):
		for z in range(-metade_profundidade, metade_profundidade + passo_rua, passo_rua):
			var em_rua_vertical: bool = ruas_verticais.has(x)
			var em_rua_horizontal: bool = ruas_horizontais.has(z)

			if not em_rua_vertical and not em_rua_horizontal:
				continue

			if em_rua_vertical and em_rua_horizontal:
				criar_instancia(estrada_cruzamento, Vector3(x, 0.0, z), 0.0)
			elif em_rua_horizontal:
				var peca_horizontal: PackedScene = estrada_faixa if z == 0 and x % 8 == 4 else estrada_reta
				criar_instancia(peca_horizontal, Vector3(x, 0.0, z), 90.0)
			else:
				var peca_vertical: PackedScene = estrada_faixa if x == 24 and abs(z) == 4 else estrada_reta
				criar_instancia(peca_vertical, Vector3(x, 0.0, z), 0.0)

func gerar_predios() -> void:
	var metade_profundidade: int = profundidade_cidade / 2

	for x in range(2, tamanho_cidade, espacamento_predios):
		if ruas_verticais.has(x):
			continue

		for z in range(-metade_profundidade, metade_profundidade + 1, espacamento_predios):
			if ruas_horizontais.has(z):
				continue

			var rotacao: float = 0.0 if z < rua_horizontal_mais_proxima(z) else 180.0
			criar_predio(Vector3(x, 0.1, z), rotacao)

func criar_predio(pos: Vector3, rot_y: float) -> void:
	var cena: PackedScene = predios.pick_random()
	var predio: Node3D = cena.instantiate() as Node3D

	add_child(predio)
	predio.position = pos
	predio.rotation_degrees.y = rot_y

	var body: StaticBody3D = StaticBody3D.new()
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()

	shape.size = Vector3(2.1, randf_range(6.0, 10.0), 2.1)
	collision.shape = shape
	body.add_child(collision)
	body.position.y = shape.size.y * 0.5

	predio.add_child(body)

func gerar_mobiliario_urbano() -> void:
	for z in ruas_horizontais:
		for x in range(2, tamanho_cidade, 4):
			if ruas_verticais.has(x):
				continue

			criar_instancia(poste, Vector3(x, 0.1, z - 2), 0.0)
			criar_instancia(poste, Vector3(x, 0.1, z + 2), 180.0)

			if randf() <= chance_decoracao:
				var deslocamento_z: int = -3 if randi() % 2 == 0 else 3
				var decoracao: PackedScene = decoracoes.pick_random()
				criar_instancia(
					decoracao,
					Vector3(x + randf_range(-0.4, 0.4), 0.05, z + deslocamento_z + randf_range(-0.4, 0.4)),
					float(randi() % 4) * 90.0
				)

	for x in ruas_verticais:
		for z in ruas_horizontais:
			criar_instancia(semaforo, Vector3(x - 1, 0.1, z - 1), 0.0)
			criar_instancia(semaforo, Vector3(x + 1, 0.1, z - 1), 90.0)
			criar_instancia(semaforo, Vector3(x + 1, 0.1, z + 1), 180.0)
			criar_instancia(semaforo, Vector3(x - 1, 0.1, z + 1), 270.0)

func gerar_ponto_marcante() -> void:
	criar_instancia(caixa_agua, Vector3(tamanho_cidade - 6, 0.1, profundidade_cidade / 2 + 2), 180.0)

func criar_instancia(cena: PackedScene, posicao: Vector3, rotacao_y: float) -> Node3D:
	var instancia: Node3D = cena.instantiate() as Node3D
	add_child(instancia)
	instancia.position = posicao
	instancia.rotation_degrees.y = rotacao_y
	return instancia

func rua_horizontal_mais_proxima(z: int) -> int:
	var rua_mais_proxima: int = ruas_horizontais[0]
	var menor_distancia: int = abs(z - rua_mais_proxima)

	for rua in ruas_horizontais:
		var distancia: int = abs(z - rua)
		if distancia < menor_distancia:
			menor_distancia = distancia
			rua_mais_proxima = rua

	return rua_mais_proxima
