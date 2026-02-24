extends Area2D

# Enemy properties
@export var max_health: float = 30.0
@export var current_health: float = 30.0

# Movement properties
@export var speed: float = 150.0  # Chase speed
@export var rotation_speed: float = 5.0  # How fast enemy rotates to face player
@export var min_distance: float = 50.0  # Minimum distance to maintain from player

# Reference to player
var player: Node2D = null

func _ready() -> void:
	current_health = max_health

	# Find the player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Enemy: No player found in 'player' group")

func _process(delta: float) -> void:
	# If no player or player is destroyed, stop processing
	if player == null or not is_instance_valid(player):
		return

	# Calculate direction to player
	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)

	# Rotate to face player
	var target_rotation = direction_to_player.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Move towards player only if farther than minimum distance
	if distance_to_player > min_distance:
		position += direction_to_player * speed * delta

func take_damage(amount: float) -> void:
	current_health -= amount
	print("Enemy hit! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	queue_free()
