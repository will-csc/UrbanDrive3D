extends Node3D

var predios = [
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_A.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_B.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_C.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_E.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_F.gltf"),
	preload("res://addons/kaykit_city_builder_bits/Assets/gltf/building_G.gltf")
]

var estrada = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/road_straight.gltf")
var semaforo = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/trafficlight_A.gltf")
var poste = preload("res://addons/kaykit_city_builder_bits/Assets/gltf/streetlight.gltf")

@export var tamanho_cidade := 40
@export var espacamento := 4

func _ready():
	randomize()
	gerar_estrada()
	gerar_cidade()

func gerar_cidade():

	for x in range(0, tamanho_cidade, espacamento):

		criar_predio(Vector3(x, 0.1, -4), 0)

		criar_predio(Vector3(x, 0.1, 4), 180)

func criar_predio(pos, rot_y):

	var cena = predios.pick_random()
	var predio = cena.instantiate()

	add_child(predio)

	predio.position = pos
	predio.rotation_degrees.y = rot_y

	var body = StaticBody3D.new()

	var collision = CollisionShape3D.new()

	var shape = BoxShape3D.new()

	# tamanho da colisão
	shape.size = Vector3(2, 8, 2)

	collision.shape = shape

	body.add_child(collision)

	# altura da colisão
	body.position.y = 4

	predio.add_child(body)

func gerar_estrada():

	for x in range(0, tamanho_cidade, 2):

		var rua = estrada.instantiate()

		add_child(rua)

		rua.position = Vector3(x, 0, 0)
		
		rua.rotation_degrees.y = 90
