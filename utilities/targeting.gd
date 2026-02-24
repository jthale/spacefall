extends Node

# Targeting strategies
enum TargetPriority {
	PRIORITIZE_STATION,  # Station first, player if close (based on aggro_range)
	ALWAYS_PLAYER,       # Always chase player
	ALWAYS_STATION,      # Always chase station
	CLOSEST,             # Chase whichever is closer
}

# Targeting properties
@export var priority: TargetPriority = TargetPriority.PRIORITIZE_STATION
@export var aggro_range: float = 100.0  # Used for PRIORITIZE_STATION strategy

# Signals
signal target_changed(new_target: Node2D)

# References
var player: Node2D = null
var space_station: Node2D = null
var current_target: Node2D = null

func _ready() -> void:
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Targeting: No player found in 'player' group")

	# Find the space station
	space_station = get_tree().get_first_node_in_group("space_station")
	if space_station == null:
		push_warning("Targeting: No space station found in 'space_station' group")

func _process(_delta: float) -> void:
	update_target()

func update_target() -> void:
	var new_target: Node2D = null

	match priority:
		TargetPriority.PRIORITIZE_STATION:
			new_target = get_prioritize_station_target()
		TargetPriority.ALWAYS_PLAYER:
			new_target = get_player_target()
		TargetPriority.ALWAYS_STATION:
			new_target = get_station_target()
		TargetPriority.CLOSEST:
			new_target = get_closest_target()

	# Emit signal if target changed
	if new_target != current_target:
		current_target = new_target
		target_changed.emit(current_target)

func get_prioritize_station_target() -> Node2D:
	# Prioritize space station, but switch to player if they get too close
	if player and is_instance_valid(player):
		var distance_to_player = get_parent().global_position.distance_to(player.global_position)
		if distance_to_player < aggro_range:
			return player

	# Default to space station
	if space_station and is_instance_valid(space_station):
		return space_station

	return null

func get_player_target() -> Node2D:
	if player and is_instance_valid(player):
		return player
	return null

func get_station_target() -> Node2D:
	if space_station and is_instance_valid(space_station):
		return space_station
	return null

func get_closest_target() -> Node2D:
	var valid_player = player and is_instance_valid(player)
	var valid_station = space_station and is_instance_valid(space_station)

	if not valid_player and not valid_station:
		return null

	if valid_player and not valid_station:
		return player

	if valid_station and not valid_player:
		return space_station

	# Both valid, return closest
	var parent_pos = get_parent().global_position
	var dist_to_player = parent_pos.distance_to(player.global_position)
	var dist_to_station = parent_pos.distance_to(space_station.global_position)

	return player if dist_to_player < dist_to_station else space_station

func get_current_target() -> Node2D:
	return current_target
