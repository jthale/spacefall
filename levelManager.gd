extends Node

# Respawn configuration
@export var respawn_delay: float = 3.0  # Time before player respawns (seconds)
@export var respawn_point: Node2D  # Marker2D or other Node2D to respawn at

# References
var player: Node2D = null
var player_health: Node = null
var respawn_timer: float = 0.0
var is_respawning: bool = false

func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("LevelManager: No player found in 'player' group")
		return

	# Find player's Health component
	player_health = player.get_node_or_null("Health")
	if player_health == null:
		push_error("LevelManager: Player has no Health component")
		return

	# Connect to player's death signal
	if player_health.has_signal("died"):
		player_health.died.connect(_on_player_died)
		print("LevelManager: Connected to player death signal")
	else:
		push_error("LevelManager: Player Health has no 'died' signal")

func _process(delta: float) -> void:
	# Handle respawn timer
	if is_respawning:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_player()

func _on_player_died() -> void:
	print("LevelManager: Player died, respawning in ", respawn_delay, " seconds")
	is_respawning = true
	respawn_timer = respawn_delay

	# Hide player while respawning (optional)
	if player:
		player.visible = false

func respawn_player() -> void:
	if player == null or player_health == null:
		push_error("LevelManager: Cannot respawn - player or health missing")
		return

	if respawn_point == null:
		push_error("LevelManager: No respawn point set")
		return

	# Move player to respawn point
	player.global_position = respawn_point.global_position
	player.rotation = 0  # Reset rotation
	player.visible = true

	# Reset player health to full
	if player_health.has_method("heal"):
		player_health.current_health = player_health.max_health
		player_health.update_health_bar()

	is_respawning = false
	print("LevelManager: Player respawned at ", respawn_point.global_position)
