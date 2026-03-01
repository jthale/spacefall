extends Node2D

# Weapon properties
@export var fire_rate: float = 1.5  # Time between shots in seconds
@export var projectile_scene: PackedScene  # Assign enemy_projectile.tscn in the editor
@export var damage: float = 10.0  # Damage dealt by projectiles
@export var max_range: float = 400.0  # Maximum range to shoot
@export var rotation_speed: float = 5.0  # How fast weapon rotates to face target (when using own targeting)

# Timer for firing
var time_since_last_shot: float = 0.0
var current_target: Node2D = null  # Set by parent enemy or own targeting system
var has_own_targeting: bool = false  # Whether this weapon has independent targeting
var targeting_system: Node = null

func _ready() -> void:
	# Check for child Targeting node
	targeting_system = find_child("Targeting")
	if targeting_system != null:
		has_own_targeting = true
		# Connect to targeting system signal
		if targeting_system.has_signal("target_changed"):
			targeting_system.target_changed.connect(_on_target_changed)
		else:
			push_warning("Weapon: Targeting node found but has no target_changed signal")

func _process(delta: float) -> void:
	# Update fire timer
	time_since_last_shot += delta

	# Get target from own targeting or parent
	if not has_own_targeting:
		# Pull target from parent enemy if we don't have our own targeting
		if get_parent() and get_parent().has_method("get_target"):
			current_target = get_parent().get_target()

	# Rotate weapon to face target if we have independent targeting
	if has_own_targeting and current_target != null and is_instance_valid(current_target):
		var direction_to_target = (current_target.global_position - global_position).normalized()
		var target_rotation = direction_to_target.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Fire projectile if enough time has passed
	if time_since_last_shot >= fire_rate:
		# Check if current target is in range
		if is_target_in_range():
			fire_projectile(current_target)
			time_since_last_shot = 0.0

func _on_target_changed(new_target: Node2D) -> void:
	# Called by child Targeting node when target changes
	current_target = new_target

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

	# Pass damage to projectile
	if projectile.has_method("set_damage"):
		projectile.set_damage(damage)
