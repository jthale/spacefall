extends Node2D

# Weapon properties
@export var fire_rate: float = 1.5  # Time between shots in seconds
@export var projectile_scene: PackedScene  # Assign enemy_projectile.tscn in the editor
@export var max_range: float = 400.0  # Maximum range to shoot

# Timer for firing
var time_since_last_shot: float = 0.0
var current_target: Node2D = null  # Set by parent enemy

func _process(delta: float) -> void:
	# Update fire timer
	time_since_last_shot += delta

	# Fire projectile if enough time has passed
	if time_since_last_shot >= fire_rate:
		# Check if current target is in range
		if is_target_in_range():
			fire_projectile(current_target)
			time_since_last_shot = 0.0

func set_target(target: Node2D) -> void:
	current_target = target

func is_target_in_range() -> bool:
	if current_target == null or not is_instance_valid(current_target):
		return false

	# Check if target is within range
	var distance = global_position.distance_to(current_target.global_position)
	return distance <= max_range

func fire_projectile(target: Node2D) -> void:
	if projectile_scene == null:
		push_warning("Enemy Weapon: No projectile scene assigned")
		return

	if target == null:
		return

	# Store weapon position before instantiating
	var spawn_position = global_position

	# Create projectile instance
	var projectile = projectile_scene.instantiate()

	# Calculate direction to target
	var direction = (target.global_position - spawn_position).normalized()

	# Set projectile position and rotation BEFORE adding to tree
	projectile.position = spawn_position
	projectile.rotation = direction.angle()

	# Add projectile to the main scene (not as child of weapon)
	get_tree().root.add_child(projectile)

	# Pass target direction to projectile
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
