extends CharacterBody2D

@export var speed: float = 100.0
@export var repath_interval: float = 0.5

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target: Area2D
var has_reached_keep: bool = false
var repath_timer: float = 0.0


func _ready() -> void:
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	call_deferred("find_keep")


func find_keep() -> void:
	target = get_tree().get_first_node_in_group("keep") as Area2D

	if target == null:
		print("ERRO: Enemy não encontrou o Keep!")
		return

	navigation_agent.target_position = target.global_position


func _physics_process(delta: float) -> void:
	if target == null:
		return

	if has_reached_keep:
		return

	repath_timer -= delta

	if repath_timer <= 0.0:
		navigation_agent.target_position = target.global_position
		repath_timer = repath_interval

	var next_position := navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)

	var desired_velocity := direction * speed
	navigation_agent.velocity = desired_velocity


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if has_reached_keep:
		return

	velocity = safe_velocity
	move_and_slide()


func reach_keep() -> void:
	if has_reached_keep:
		return

	has_reached_keep = true
	velocity = Vector2.ZERO
	navigation_agent.velocity = Vector2.ZERO

	queue_free()
