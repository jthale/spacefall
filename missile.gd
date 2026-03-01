extends Area2D

# Missile properties
@export var speed: float = 400.0  # Missile speed
@export var lifetime: float = 5.0  # Time before missile auto-destroys (seconds)
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
	# Move missile in its direction
	position += direction * speed * delta

	# Update lifetime
	time_alive += delta

	# Destroy missile after lifetime expires
	if time_alive >= lifetime:
		queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

func set_damage(new_damage: float) -> void:
	damage = new_damage

func _on_area_entered(area: Area2D) -> void:
	# When missile hits something

	# Prevent friendly fire - check if missile and area are in the same group
	if is_in_group("enemy") and area.is_in_group("enemy"):
		return  # Enemy missile hit an enemy, ignore it
	if is_in_group("player") and area.is_in_group("player"):
		return  # Player missile hit player, ignore it

	if area.has_method("take_damage"):
		area.take_damage(damage)

	# Destroy the missile on impact
	queue_free()
