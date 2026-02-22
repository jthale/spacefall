extends Node2D

# Turret properties
@export var fire_rate: float = 3.0  # Time between shots in seconds
@export var missile_scene: PackedScene  # Assign missile.tscn in the editor
@export var target_group: String = "enemy"  # Group to search for targets (default: "enemy")

# Reference to the current target
var current_target: Node2D = null

# Timer for firing
var time_since_last_shot: float = 0.0

func _ready() -> void:
	# Initial target acquisition
	find_closest_target()

func _process(delta: float) -> void:
	# Check if current target is still valid (not destroyed)
	if current_target == null or not is_instance_valid(current_target):
		find_closest_target()

	# If still no target, stop processing
	if current_target == null:
		return

	# Always rotate to face the target
	var direction_to_target = (current_target.global_position - global_position).normalized()
	rotation = direction_to_target.angle()

	# Update fire timer
	time_since_last_shot += delta

	# Fire missile if enough time has passed
	if time_since_last_shot >= fire_rate:
		fire_missile()
		time_since_last_shot = 0.0

func find_closest_target() -> void:
	# Get all nodes in the target group
	var targets = get_tree().get_nodes_in_group(target_group)

	if targets.is_empty():
		current_target = null
		return

	# Find the closest target
	var closest_distance: float = INF
	var closest_target: Node2D = null

	for target in targets:
		if target is Node2D:
			var distance = global_position.distance_to(target.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = target

	current_target = closest_target

func fire_missile() -> void:
	if missile_scene == null:
		push_warning("Turret: No missile scene assigned")
		return

	if current_target == null:
		return

	# Create missile instance
	var missile = missile_scene.instantiate()

	# Add missile to the main scene (not as child of turret)
	get_tree().root.add_child(missile)

	# Set missile position to turret position
	missile.global_position = global_position

	# Calculate direction to target
	var direction = (current_target.global_position - global_position).normalized()

	# Set missile rotation and pass target direction
	missile.rotation = direction.angle()
	if missile.has_method("set_direction"):
		missile.set_direction(direction)
