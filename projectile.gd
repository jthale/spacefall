extends Area2D

# Projectile properties
@export var speed: float = 500.0  # Projectile speed
@export var lifetime: float = 3.0  # Time before projectile auto-destroys (seconds)
@export var damage: float = 10.0  # Damage dealt on hit

# Movement direction
var direction: Vector2 = Vector2.RIGHT

# Lifetime timer
var time_alive: float = 0.0

func _ready() -> void:
	# Start with the default direction based on rotation
	direction = Vector2.RIGHT.rotated(rotation)

	# Connect to the area_entered signal to detect collisions
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Move projectile in its direction
	position += direction * speed * delta

	# Update lifetime
	time_alive += delta

	# Destroy projectile after lifetime expires
	if time_alive >= lifetime:
		queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

func _on_area_entered(area: Area2D) -> void:

	# When projectile hits something
	if area.has_method("take_damage"):
		area.take_damage(damage)

	# Destroy the projectile on impact
	queue_free()
