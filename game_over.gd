extends Node

# UI References - set these in the inspector
@export var win_label: Label
@export var lose_label: Label

# Reference to level manager
var level_manager: Node = null

func _ready() -> void:
	# Hide both labels initially
	if win_label:
		win_label.visible = false
	if lose_label:
		lose_label.visible = false

	# Find the level manager
	level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager == null:
		# Try finding it as a child of the main scene
		var main = get_tree().root.get_node_or_null("Main")
		if main:
			level_manager = main.get_node_or_null("Level Manager")

	if level_manager == null:
		push_error("GameOver: No level manager found")
		return

	# Connect to game state signals
	if level_manager.has_signal("game_won"):
		level_manager.game_won.connect(_on_game_won)
		print("GameOver: Connected to game_won signal")
	else:
		push_error("GameOver: Level manager has no 'game_won' signal")

	if level_manager.has_signal("game_lost"):
		level_manager.game_lost.connect(_on_game_lost)
		print("GameOver: Connected to game_lost signal")
	else:
		push_error("GameOver: Level manager has no 'game_lost' signal")

func _on_game_won() -> void:
	print("GameOver: Showing victory screen")

	# Hide lose label, show win label
	if lose_label:
		lose_label.visible = false
	if win_label:
		win_label.visible = true
	else:
		push_warning("GameOver: No win label set in inspector")

func _on_game_lost() -> void:
	print("GameOver: Showing defeat screen")

	# Hide win label, show lose label
	if win_label:
		win_label.visible = false
	if lose_label:
		lose_label.visible = true
	else:
		push_warning("GameOver: No lose label set in inspector")
