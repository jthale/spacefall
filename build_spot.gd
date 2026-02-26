extends Area2D

# What can be built at this spot (e.g., turret.tscn)
@export var buildable_scene: PackedScene
@export var building_cost: int = 1  # Cost in credits to build

# Building state
var is_built: bool = false
var built_structure: Node2D = null
var preview_structure: Node2D = null
var player_nearby: bool = false
var building_enabled: bool = true

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Connect to wave manager signals
	var wave_manager = get_node_or_null("/root/Main/Wave Manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_ended.connect(_on_wave_ended)

func _on_area_entered(area):
	if area.is_in_group("player") and not is_built and building_enabled:
		player_nearby = true
		show_preview()

func _on_area_exited(area):
	if area.is_in_group("player"):
		player_nearby = false
		hide_preview()

func show_preview():
	if buildable_scene and not preview_structure:
		# Hide all sprite children (build spot visual)
		for child in get_children():
			if child is Sprite2D:
				child.visible = false

		# Instantiate the building as a preview (add to parent, not as child)
		preview_structure = buildable_scene.instantiate()
		get_parent().add_child(preview_structure)
		preview_structure.global_position = global_position

		# Set to 50% alpha for preview effect
		preview_structure.modulate = Color(1, 1, 1, 0.5)

		# Disable any scripts/functionality on the preview
		if preview_structure.has_method("set_physics_process"):
			preview_structure.set_physics_process(false)
		if preview_structure.has_method("set_process"):
			preview_structure.set_process(false)

func hide_preview():
	if preview_structure and not is_built:
		preview_structure.queue_free()
		preview_structure = null

		# Show all sprite children again
		for child in get_children():
			if child is Sprite2D:
				child.visible = true

func _on_wave_started():
	building_enabled = false
	# Hide the entire build spot during wave
	visible = false
	# Hide preview if player is currently near a build spot
	if preview_structure:
		hide_preview()

func _on_wave_ended():
	building_enabled = true
	# Show the build spot again after wave
	if not is_built:
		visible = true
	# Show preview again if player is still nearby
	if player_nearby and not is_built:
		show_preview()

func _input(event):
	if player_nearby and not is_built and building_enabled:
		if event.is_action_pressed("build"):
			build()

func build():
	if buildable_scene and not is_built and preview_structure:
		# Attempt to spend the credits
		if not Economy.spend(building_cost):
			print("BuildSpot: Cannot afford building (Cost: %d, Current: %d)" % [building_cost, Economy.get_credits()])
			return

		# Make the preview fully opaque and enable it
		preview_structure.modulate = Color(1, 1, 1, 1.0)

		# Re-enable functionality
		if preview_structure.has_method("set_physics_process"):
			preview_structure.set_physics_process(true)
		if preview_structure.has_method("set_process"):
			preview_structure.set_process(true)

		# Mark as built
		built_structure = preview_structure
		preview_structure = null
		is_built = true

		print("BuildSpot: Building constructed! Remaining credits: %d" % Economy.get_credits())

		# Remove the build spot since it's no longer needed
		queue_free()
