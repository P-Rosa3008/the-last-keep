extends Node

@export var enemy_scene: PackedScene
@export var enemy_count: int = 10
@export var spawn_delay: float = 0.75
@export var enemy_radius: float = 26.0

@onready var enemies: Node2D = $"../Enemies"
@onready var navigation_region: NavigationRegion2D = $"../NavigationRegion"

var spawn_areas: Array[Node] = []


func _ready() -> void:
	spawn_areas = get_tree().get_nodes_in_group("spawn_area")

	if spawn_areas.is_empty():
		print("ERRO: Não existem SpawnAreas no grupo 'spawn_area'!")
		return

	start_wave()


func start_wave() -> void:
	for i in range(enemy_count):
		spawn_enemy()
		await get_tree().create_timer(spawn_delay).timeout


func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemies.add_child(enemy)

	var spawn_area := spawn_areas.pick_random() as Area2D
	enemy.global_position = get_random_spawn_position(spawn_area)


func get_random_spawn_position(spawn_area: Area2D) -> Vector2:
	var spawn_shape := spawn_area.get_node("CollisionShape2D") as CollisionShape2D
	var rectangle := spawn_shape.shape as RectangleShape2D

	if rectangle == null:
		print("ERRO: ", spawn_area.name, " precisa de uma RectangleShape2D!")
		return spawn_area.global_position

	var usable_half_size := rectangle.size / 2.0 - Vector2(
		enemy_radius,
		enemy_radius
	)

	if usable_half_size.x <= 0.0 or usable_half_size.y <= 0.0:
		print("ERRO: ", spawn_area.name, " é demasiado pequena!")
		return spawn_area.global_position

	var navigation_map: RID = navigation_region.get_navigation_map()

	for attempt in range(50):
		var random_offset := Vector2(
			randf_range(-usable_half_size.x, usable_half_size.x),
			randf_range(-usable_half_size.y, usable_half_size.y)
		)

		var random_position: Vector2 = spawn_shape.to_global(random_offset)

		var navigation_position: Vector2 = NavigationServer2D.map_get_closest_point(
			navigation_map,
			random_position
		)

		if random_position.distance_to(navigation_position) < 1.0:
			return random_position

	print("AVISO: Não foi encontrada posição válida em ", spawn_area.name)
	return spawn_area.global_position
