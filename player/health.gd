extends Node

# Health properties
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var destroy_on_death: bool = true  # Whether to queue_free the parent on death

# Signals for other systems to respond to
signal health_changed(new_health: float, max_health: float)
signal damaged(amount: float)
signal died()

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return  # Already dead

	current_health -= amount
	current_health = max(0, current_health)  # Clamp to 0

	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

	print(get_parent().name, " hit! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	current_health += amount
	current_health = min(current_health, max_health)  # Clamp to max
	health_changed.emit(current_health, max_health)

func die() -> void:
	print(get_parent().name, " destroyed!")
	died.emit()

	if destroy_on_death:
		get_parent().queue_free()

func is_alive() -> bool:
	return current_health > 0

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0
