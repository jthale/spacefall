extends Area2D

@export var building_node: Node2D  # Reference to the Building node in parent
@export var building_cost: int = 1  # Cost in credits to build

# Building state
var is_built: bool = false
var preview_structure: Node2D = null
var player_nearby: bool = false
var building_enabled: bool = true

# References
@onready var cost_label: Label = $Cost

func _ready():
	# Set cost label text and hide it initially
	if cost_label:
		cost_label.text = str(building_cost)
		cost_label.visible = false

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _process(_delta):
	# Only active build spots that player is near should show preview
	if player_nearby and not is_built and building_enabled:
		if is_closest_to_player():
			if not preview_structure:
				show_preview()
		else:
			if preview_structure:
				hide_preview()

func _on_area_entered(area):
	if area.is_in_group("player") and not is_built and building_enabled:
		player_nearby = true

func _on_area_exited(area):
	if area.is_in_group("player"):
		player_nearby = false
		if preview_structure:
			hide_preview()

func show_preview():
	if not preview_structure:
		if not building_node:
			push_error("BuildSpot: building_node must be set in the inspector")
			return

		# Use the building node as preview
		preview_structure = building_node
		preview_structure.visible = true
		preview_structure.modulate = Color(1, 1, 1, 0.5)

		# Hide all sprite children (build spot visual)
		for child in get_children():
			if child is Sprite2D:
				child.visible = false

		# Show cost label
		if cost_label:
			cost_label.visible = true

func hide_preview():
	if preview_structure and not is_built:
		# Hide and reset modulate for parent's building
		preview_structure.visible = false
		preview_structure.modulate = Color(1, 1, 1, 1.0)
		preview_structure = null

		# Hide cost label
		if cost_label:
			cost_label.visible = false

		# Show all sprite children again
		for child in get_children():
			if child is Sprite2D:
				child.visible = true

func _input(event):
	if player_nearby and not is_built and building_enabled:
		if event.is_action_pressed("build"):
			build()

func build():
	if not get_parent() or not get_parent().has_method("show_building"):
		push_error("BuildSpot: Parent must have show_building() method")
		return

	# Attempt to spend the credits
	if not Economy.spend(building_cost):
		print("BuildSpot: Cannot afford building (Cost: %d, Current: %d)" % [building_cost, Economy.get_credits()])
		return

	# Tell parent to show the building and hide build spot
	get_parent().show_building()

	# Mark as built
	is_built = true

	print("BuildSpot: Building constructed! Remaining credits: %d" % Economy.get_credits())

func is_closest_to_player() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false

	var my_distance = global_position.distance_to(player.global_position)

	# Check all other build spots
	var build_spots = get_tree().get_nodes_in_group("build_spots")
	for spot in build_spots:
		if spot == self or spot.is_built or not spot.player_nearby:
			continue
		var their_distance = spot.global_position.distance_to(player.global_position)
		if their_distance < my_distance:
			return false  # Another spot is closer

	return true
