extends Node

# Priority-based targeting system
# Searches groups in order and targets closest entity in the highest priority group found
@export var target_priorities: Array[String] = ["buildings", "space_station"]
@export var aggro_range: float = -1.0  # Optional: switch to "player" if within range (-1 = disabled)

# Signals
signal target_changed(new_target: Node2D)

# Current target reference
var current_target: Node2D = null

func _process(_delta: float) -> void:
	update_target()

func update_target() -> void:
	var new_target: Node2D = null
	var parent_pos = get_parent().global_position

	# Check aggro override first (player proximity)
	if aggro_range > 0:
		var player = get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player):
			if parent_pos.distance_to(player.global_position) < aggro_range:
				new_target = player

	# If no aggro override, search priority groups in order
	if new_target == null:
		for group_name in target_priorities:
			var targets = get_tree().get_nodes_in_group(group_name)
			if targets.is_empty():
				continue

			# Find closest valid target in this group
			var closest = null
			var closest_dist = INF

			for target in targets:
				if not is_instance_valid(target):
					continue
				# Skip destroyed buildings
				if "is_destroyed" in target and target.is_destroyed:
					continue
				var dist = parent_pos.distance_to(target.global_position)
				if dist < closest_dist:
					closest = target
					closest_dist = dist

			if closest != null:
				new_target = closest
				break  # Found target in highest priority group, stop searching

	# Emit signal if target changed
	if new_target != current_target:
		current_target = new_target
		target_changed.emit(current_target)

func get_current_target() -> Node2D:
	return current_target
