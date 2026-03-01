extends Node2D

# Weapon properties
@export var fire_rate: float = 0.5  # Time between shots in seconds
@export var projectile_scene: PackedScene  # Assign projectile.tscn in the editor
@export var damage: float = 10.0  # Damage dealt by projectiles
@export var target_group: String = "enemy"  # Group to search for targets
@export var max_range: float = 0.0  # Maximum range to shoot (0 = infinite)
@export var retarget_interval: float = 1.0  # How often to re-evaluate closest target (seconds)

# Internal state
var current_target: Node2D = null
var time_since_last_shot: float = 0.0
var time_since_retarget: float = 0.0

func _ready() -> void:
	# Initial target acquisition
	find_closest_target()

func _process(delta: float) -> void:
	# Quick validity check (very cheap)
	var needs_retarget = current_target == null or not is_instance_valid(current_target)

	# Periodic retargeting to find closer enemies
	if not needs_retarget:
		time_since_retarget += delta
		if time_since_retarget >= retarget_interval:
			needs_retarget = true
			time_since_retarget = 0.0

	# Only do expensive search when necessary
	if needs_retarget:
		find_closest_target()

	# If still no target, stop processing
	if current_target == null:
		return

	# Update fire timer
	time_since_last_shot += delta

	# Fire projectile if enough time has passed and target is in range
	if time_since_last_shot >= fire_rate:
		if is_target_in_range():
			fire_projectile()
			time_since_last_shot = 0.0

func find_closest_target() -> void:
	# Get all nodes in the target group
	var targets = get_tree().get_nodes_in_group(target_group)

	if targets.is_empty():
		current_target = null
		return

	# Find the closest target (optionally within range)
	var closest_distance: float = INF
	var closest_target: Node2D = null

	for target in targets:
		if target is Node2D and is_instance_valid(target):
			var distance = global_position.distance_to(target.global_position)

			# If max_range is set, only consider targets within range
			if max_range > 0 and distance > max_range:
				continue

			if distance < closest_distance:
				closest_distance = distance
				closest_target = target

	current_target = closest_target

func is_target_in_range() -> bool:
	if current_target == null or not is_instance_valid(current_target):
		return false

	# If max_range is 0, always in range
	if max_range <= 0:
		return true

	# Check if target is within range
	var distance = global_position.distance_to(current_target.global_position)
	return distance <= max_range

func fire_projectile() -> void:
	if projectile_scene == null:
		push_warning("Weapon: No projectile scene assigned")
		return

	if current_target == null:
		return

	# Store weapon position before instantiating
	var spawn_position = global_position

	# Create projectile instance
	var projectile = projectile_scene.instantiate()

	# Calculate direction to target at time of firing
	var direction = (current_target.global_position - spawn_position).normalized()

	# Set projectile position and rotation BEFORE adding to tree
	projectile.position = spawn_position
	projectile.rotation = direction.angle()

	# Add projectile to the main scene (not as child of weapon)
	get_tree().root.add_child(projectile)

	# Pass target direction to projectile
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)

	# Pass damage to projectile
	if projectile.has_method("set_damage"):
		projectile.set_damage(damage)

# Optional: Allow external target setting (for special cases)
func set_target(target: Node2D) -> void:
	current_target = target
