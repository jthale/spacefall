extends Node2D

# Weapon properties
@export var fire_rate: float = 1.5  # Time between shots in seconds
@export var projectile_scene: PackedScene  # Assign enemy_projectile.tscn in the editor
@export var target_group: String = "player"  # Group to search for targets
@export var max_range: float = 400.0  # Maximum range to find and shoot at player

# Timer for firing
var time_since_last_shot: float = 0.0

func _process(delta: float) -> void:
	# Update fire timer
	time_since_last_shot += delta

	# Fire projectile if enough time has passed
	if time_since_last_shot >= fire_rate:
		# Check if player is in range
		var target = is_player_in_range()
		if target != null:
			fire_projectile(target)
			time_since_last_shot = 0.0
		else:
			print("Enemy weapon: No target in range")

func is_player_in_range() -> Node2D:
	# Get the player (there's only one)
	var player = get_tree().get_first_node_in_group(target_group)

	if player == null or not is_instance_valid(player):
		return null

	# Check if player is within range
	var distance = global_position.distance_to(player.global_position)
	if distance <= max_range:
		return player

	return null

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
