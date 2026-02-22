extends Area2D

# Enemy properties
@export var max_health: float = 30.0
@export var current_health: float = 30.0

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Enemy hit! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	queue_free()
