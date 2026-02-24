extends Area2D

# Movement properties
@export var speed: float = 150.0  # Chase speed
@export var rotation_speed: float = 5.0  # How fast enemy rotates to face player
@export var min_distance: float = 50.0  # Minimum distance to maintain from target

# Targeting properties
@export var aggro_range: float = 100.0  # Distance at which enemy switches from station to player

# References
var player: Node2D = null
var space_station: Node2D = null
var current_target: Node2D = null
var weapon: Node2D = null

func _ready() -> void:
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Enemy: No player found in 'player' group")

	# Find the space station
	space_station = get_tree().get_first_node_in_group("space_station")
	if space_station == null:
		push_warning("Enemy: No space station found in 'space_station' group")

	# Find the weapon child node
	weapon = find_child("Weapon")
	if weapon == null:
		push_warning("Enemy: No weapon found")

func _process(delta: float) -> void:
	# Determine target based on priority: player if close, otherwise space station
	update_target()

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

func update_target() -> void:
	# Prioritize space station, but switch to player if they get too close
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < aggro_range:
			current_target = player
			update_weapon_target()
			return

	# Default to space station
	if space_station and is_instance_valid(space_station):
		current_target = space_station
	else:
		current_target = null

	update_weapon_target()

func update_weapon_target() -> void:
	# Tell the weapon what to shoot at
	if weapon and weapon.has_method("set_target"):
		weapon.set_target(current_target)
