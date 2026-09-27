@tool
extends Node2D


@export var size: Vector2 = Vector2(200, 100)

var last_size: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	if size != last_size:
		last_size = size
		update_obstacle()


func _ready() -> void:
	last_size = size
	update_obstacle()


func update_obstacle() -> void:
	print("OBSTACLE UPDATE: ", size)

	var body := get_node_or_null("Body") as Polygon2D
	var collision := get_node_or_null("StaticBody2D/CollisionShape2D") as CollisionShape2D

	if body == null:
		print("ERRO: Body não encontrado")
		return

	if collision == null:
		print("ERRO: CollisionShape2D não encontrado")
		return

	var safe_size := Vector2(
		max(size.x, 1.0),
		max(size.y, 1.0)
	)

	var half_size := safe_size / 2.0

	body.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])

	var rectangle := collision.shape as RectangleShape2D

	if rectangle == null:
		rectangle = RectangleShape2D.new()
		collision.shape = rectangle

	rectangle.size = safe_size
	collision.position = Vector2.ZERO
