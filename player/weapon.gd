extends Node2D

# Weapon properties
@export var fire_rate: float = 0.5  # Time between shots in seconds
@export var projectile_scene: PackedScene  # Assign projectile.tscn in the editor
@export var target_group: String = "enemy"  # Group to search for targets
@export var max_range: float = 300.0  # Maximum range to find and shoot at enemies

# Timer for firing
var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	# Update fire timer
	time_since_last_shot += delta

	# Fire projectile if enough time has passed
	if time_since_last_shot >= fire_rate:
		# Find closest enemy in range
		var target = find_closest_target_in_range()
		if target != null:
			fire_projectile(target)
			time_since_last_shot = 0.0

func find_closest_target_in_range() -> Node2D:
	# Get all nodes in the target group
	var targets = get_tree().get_nodes_in_group(target_group)

	if targets.is_empty():
		return null

	# Find the closest target within range
	var closest_distance: float = INF
	var closest_target: Node2D = null

	for target in targets:
		if target is Node2D and is_instance_valid(target):
			var distance = global_position.distance_to(target.global_position)
			# Only consider targets within max_range
			if distance <= max_range and distance < closest_distance:
				closest_distance = distance
				closest_target = target

	return closest_target

func fire_projectile(target: Node2D) -> void:
	if projectile_scene == null:
		push_warning("Weapon: No projectile scene assigned")
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
