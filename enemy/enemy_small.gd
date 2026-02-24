extends Area2D

# Movement properties
@export var speed: float = 150.0  # Chase speed
@export var rotation_speed: float = 5.0  # How fast enemy rotates to face player
@export var min_distance: float = 50.0  # Minimum distance to maintain from target

# References
var current_target: Node2D = null
var weapon: Node2D = null
var targeting_system: Node = null

func _ready() -> void:
	# Find the weapon child node
	weapon = find_child("Weapon")
	if weapon == null:
		push_warning("Enemy: No weapon found")

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

	# Rotate to face target
	var target_rotation = direction_to_target.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Move towards target only if farther than minimum distance
	if distance_to_target > min_distance:
		position += direction_to_target * speed * delta

func _on_target_changed(new_target: Node2D) -> void:
	# Update current target when targeting system changes it
	current_target = new_target

	# Tell the weapon what to shoot at
	if weapon and weapon.has_method("set_target"):
		weapon.set_target(current_target)
