extends Node

# Game state
enum GameState { PLAYING, WON, LOST }
var current_state: GameState = GameState.PLAYING

# Signals
signal game_won
signal game_lost

# Respawn configuration
@export var respawn_delay: float = 3.0  # Time before player respawns (seconds)
@export var respawn_point: Node2D  # Marker2D or other Node2D to respawn at

# References
var player: Node2D = null
var player_health: Node = null
var space_station: Node2D = null
var space_station_health: Node = null
var wave_manager: Node = null
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

	# Find the space station
	space_station = get_tree().get_first_node_in_group("space_station")
	if space_station == null:
		push_error("LevelManager: No space station found in 'space_station' group")
	else:
		# Find space station's Health component
		space_station_health = space_station.get_node_or_null("Health")
		if space_station_health == null:
			push_error("LevelManager: Space station has no Health component")
		elif space_station_health.has_signal("died"):
			space_station_health.died.connect(_on_space_station_destroyed)
			print("LevelManager: Connected to space station death signal")
		else:
			push_error("LevelManager: Space station Health has no 'died' signal")

	# Find the wave manager
	wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager == null:
		# Try finding it as a child of the main scene
		var main = get_tree().root.get_node_or_null("Main")
		if main:
			wave_manager = main.get_node_or_null("Wave Manager")

	if wave_manager == null:
		push_warning("LevelManager: No wave manager found")
	else:
		# Connect to all waves completed signal
		if wave_manager.has_signal("all_waves_completed"):
			wave_manager.all_waves_completed.connect(_on_all_waves_completed)
			print("LevelManager: Connected to wave manager")
		else:
			push_error("LevelManager: Wave manager has no 'all_waves_completed' signal")

func _process(delta: float) -> void:
	# Handle respawn timer
	if is_respawning:
		respawn_timer -= delta
		if respawn_timer <= 0:
			respawn_player()

func _on_player_died() -> void:
	# Only respawn if game is still playing
	if current_state != GameState.PLAYING:
		return

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

func _on_all_waves_completed() -> void:
	if current_state != GameState.PLAYING:
		return

	current_state = GameState.WON
	print("LevelManager: VICTORY! All waves defeated!")
	game_won.emit()

	# You can add victory screen logic here
	# For now, just print to console

func _on_space_station_destroyed() -> void:
	if current_state != GameState.PLAYING:
		return

	current_state = GameState.LOST
	print("LevelManager: DEFEAT! Space station destroyed!")
	game_lost.emit()

	# You can add game over screen logic here
	# For now, just print to console
