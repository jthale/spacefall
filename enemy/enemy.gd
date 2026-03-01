extends Area2D

# Movement properties
@export var speed: float = 150.0  # Chase speed
@export var rotation_speed: float = 5.0  # How fast enemy rotates to face player
@export var min_distance: float = 50.0  # Minimum distance to maintain from target

# Separation (collision avoidance) properties
@export var separation_distance: float = 60.0  # Distance to maintain from other enemies
@export var separation_force: float = 1.5  # Strength of separation steering

# References
var current_target: Node2D = null
var targeting_system: Node = null

func _ready() -> void:
	# Add to enemies group for separation behavior
	add_to_group("enemies")

	# Find the targeting system
	targeting_system = find_child("Targeting")
	if targeting_system == null:
		push_warning("Enemy: No targeting system found")
	else:
		# Connect to targeting system signal
		targeting_system.target_changed.connect(_on_target_changed)

func _process(delta: float) -> void:
	# If no valid target, stop processing
	if current_target == null or not is_instance_valid(current_target):
		return

	# Calculate direction and distance to current target
	var direction_to_target = (current_target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(current_target.global_position)

	# Calculate separation from other enemies (collision avoidance)
	var separation_vector = Vector2.ZERO
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in nearby_enemies:
		if enemy == self:
			continue
		var distance = global_position.distance_to(enemy.global_position)
		if distance < separation_distance and distance > 0:
			# Push away from nearby enemy (closer = stronger push)
			var away_vector = (global_position - enemy.global_position).normalized()
			separation_vector += away_vector / distance

	# Blend target direction with separation force
	if separation_vector.length() > 0:
		direction_to_target = (direction_to_target + separation_vector.normalized() * separation_force).normalized()

	# Rotate to face target
	var target_rotation = direction_to_target.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Move towards target only if farther than minimum distance
	if distance_to_target > min_distance:
		position += direction_to_target * speed * delta

func _on_target_changed(new_target: Node2D) -> void:
	# Update current target when targeting system changes it
	current_target = new_target

func get_target() -> Node2D:
	# Weapons call this to get the enemy's current target
	return current_target
