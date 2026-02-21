extends Node2D

# Turret properties
@export var fire_rate: float = 3.0  # Time between shots in seconds
@export var missile_scene: PackedScene  # Assign missile.tscn in the editor

# Reference to the player ship
var player: Node2D = null

# Timer for firing
var time_since_last_shot: float = 0.0

func _ready() -> void:
	# Find the player ship in the scene
	# Assuming the player ship is named "Ship" - adjust if different
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Turret: No player found in 'player' group")

func _process(delta: float) -> void:
	if player == null:
		return

	# Always rotate to face the player
	var direction_to_player = (player.global_position - global_position).normalized()
	rotation = direction_to_player.angle()

	# Update fire timer
	time_since_last_shot += delta

	# Fire missile if enough time has passed
	if time_since_last_shot >= fire_rate:
		fire_missile()
		time_since_last_shot = 0.0

func fire_missile() -> void:
	if missile_scene == null:
		push_warning("Turret: No missile scene assigned")
		return

	if player == null:
		return

	# Create missile instance
	var missile = missile_scene.instantiate()

	# Add missile to the main scene (not as child of turret)
	get_tree().root.add_child(missile)

	# Set missile position to turret position
	missile.global_position = global_position

	# Calculate direction to player
	var direction = (player.global_position - global_position).normalized()

	# Set missile rotation and pass target direction
	missile.rotation = direction.angle()
	if missile.has_method("set_direction"):
		missile.set_direction(direction)
