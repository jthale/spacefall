extends Node2D

# Missile properties
@export var speed: float = 400.0  # Missile speed
@export var lifetime: float = 5.0  # Time before missile auto-destroys (seconds)

# Movement direction
var direction: Vector2 = Vector2.RIGHT

# Lifetime timer
var time_alive: float = 0.0

func _ready() -> void:
	# Start with the default direction based on rotation
	direction = Vector2.RIGHT.rotated(rotation)

func _process(delta: float) -> void:
	# Move missile in its direction
	position += direction * speed * delta

	# Update lifetime
	time_alive += delta

	# Destroy missile after lifetime expires
	if time_alive >= lifetime:
		queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
