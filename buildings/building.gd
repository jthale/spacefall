extends Node2D

# Node references
@export var building_node: Node2D  # Reference to the Building node
@export var build_spot_node: Node2D  # Reference to the Build Spot node
@export var health_node: Node  # Reference to the Health component

# Building configuration
@export var starts_built: bool = false  # Set to true for pre-built buildings

# Building state
var survived_wave: bool = true
var is_destroyed: bool = false
var is_built: bool = false  # Track whether building has been constructed

# Visual settings
@export var destroyed_tint: Color = Color(0.4, 0.4, 0.4, 0.7)  # Dark gray with transparency

# Economy
@export var credits_per_wave: int = 0  # Credits awarded if building survives the wave

func _ready():
	# Set initial built state
	is_built = starts_built

	# Disable unbuilt buildings completely
	if not is_built:
		# Hide the building node initially (visible in editor for level design)
		building_node.process_mode = Node.PROCESS_MODE_DISABLED
		building_node.visible = false
		
		#if building_node:
		#	building_node.visible = false

		# Disable building functionality (weapons, etc.)
		# disable_building()

		# Disable collision so it can't be hit
		#if building_node is Area2D or building_node is CollisionObject2D:
		#	building_node.set_deferred("monitorable", false)
		#	building_node.set_deferred("monitoring", false)

		# Remove from targeting group so enemies don't target it
		# remove_from_group("building")
	else:
		# Building is already built, hide the build spot
		disable_build_spot()
		enable_building()

	# Connect to health component
	if health_node and health_node.has_signal("died"):
		health_node.died.connect(_on_building_destroyed)

	# Connect to wave manager to reset survival tracking and handle restoration
	var wave_manager = get_node_or_null("/root/Main/Wave Manager")
	if wave_manager:
		if wave_manager.has_signal("wave_started"):
			wave_manager.wave_started.connect(_on_wave_started)
		if wave_manager.has_signal("wave_ended"):
			wave_manager.wave_ended.connect(_on_wave_ended)

func _on_wave_started():
	# Reset survival tracking at start of each wave
	# Hide build spot if not built
	survived_wave = true

func _on_wave_ended():
	# Award credits if building survived the wave
	if not is_destroyed and credits_per_wave > 0:
		Economy.add_credits(credits_per_wave)
		print(name, " survived! Awarded ", credits_per_wave, " credits.")

	# Restore building if it was destroyed during the wave
	if is_destroyed:
		restore_building()

func _on_building_destroyed():
	survived_wave = false
	is_destroyed = true

	# Tint all sprite children to show destruction
	tint_sprites(destroyed_tint)

	# Disable functionality
	disable_building()

	print(name, " destroyed! No longer functional.")

func tint_sprites(tint_color: Color):
	# Find and tint all Sprite2D children in the Building node
	if not building_node:
		return

	for child in building_node.get_children():
		if child is Sprite2D:
			child.modulate = tint_color
		# Also check nested children (like Square/Label)
		for nested_child in child.get_children():
			if nested_child is Sprite2D:
				nested_child.modulate = tint_color

func disable_build_spot():
	build_spot_node.process_mode = Node.PROCESS_MODE_DISABLED
	build_spot_node.visible = false

func disable_building():
	# Disable child nodes by disabling processing on Building node children
	#building_node.process_mode = Node.PROCESS_MODE_DISABLED
	building_node.remove_from_group("building")
	
	for child in building_node.get_children():
		if child.has_method("set_process"):
			child.set_process(false)
		if child.has_method("set_physics_process"):
			child.set_physics_process(false)

func enable_building():
	# Re-enable child nodes in Building node
	building_node.process_mode = Node.PROCESS_MODE_INHERIT
	building_node.add_to_group("building")
	
	#for child in building_node.get_children():
		#if child.has_method("set_process"):
			#child.set_process(true)
		#if child.has_method("set_physics_process"):
			#child.set_physics_process(true)

func restore_building():
	# Called when building is respawned/repaired
	is_destroyed = false
	survived_wave = true

	# Reset sprite tint to normal
	tint_sprites(Color(1, 1, 1, 1))

	# Restore health
	health_node.current_health = health_node.max_health
	if health_node.has_method("update_health_bar"):
		health_node.update_health_bar()

	# Re-enable functionality
	enable_building()

	print(name, " restored and functional!")

func show_building():
	# Called by build spot when building is constructed
	is_built = true

	if building_node:
		building_node.visible = true
		building_node.modulate = Color(1, 1, 1, 1.0)  # Reset to full opacity

		# Enable collision so it can be hit
		if building_node is Area2D or building_node is CollisionObject2D:
			building_node.set_deferred("monitorable", true)
			building_node.set_deferred("monitoring", true)

	# Enable building functionality (weapons, etc.)
	enable_building()

	# Add to targeting group so enemies can target it
	add_to_group("building")
	build_spot_node.visible = false

	print(name, " built and now active!")
