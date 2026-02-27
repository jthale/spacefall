extends Node2D

# Building state
var survived_wave: bool = true
var is_destroyed: bool = false

# Visual settings
@export var destroyed_tint: Color = Color(0.4, 0.4, 0.4, 0.7)  # Dark gray with transparency

func _ready():
	# Connect to health component
	var health = get_node_or_null("Health")
	if health and health.has_signal("died"):
		health.died.connect(_on_building_destroyed)

	# Connect to wave manager to reset survival tracking and handle restoration
	var wave_manager = get_node_or_null("/root/Main/Wave Manager")
	if wave_manager:
		if wave_manager.has_signal("wave_started"):
			wave_manager.wave_started.connect(_on_wave_started)
		if wave_manager.has_signal("wave_ended"):
			wave_manager.wave_ended.connect(_on_wave_ended)

func _on_wave_started():
	# Reset survival tracking at start of each wave
	survived_wave = true

func _on_wave_ended():
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
	# Find and tint all Sprite2D children
	for child in get_children():
		if child is Sprite2D:
			child.modulate = tint_color

func disable_building():
	# Disable child nodes by disabling processing on all children
	for child in get_children():
		if child.has_method("set_process"):
			child.set_process(false)
		if child.has_method("set_physics_process"):
			child.set_physics_process(false)

func enable_building():
	# Re-enable child nodes
	for child in get_children():
		if child.has_method("set_process"):
			child.set_process(true)
		if child.has_method("set_physics_process"):
			child.set_physics_process(true)

func restore_building():
	# Called when building is respawned/repaired
	is_destroyed = false
	survived_wave = true

	# Reset sprite tint to normal
	tint_sprites(Color(1, 1, 1, 1))

	# Restore health
	var health = get_node_or_null("Health")
	if health and health.has_method("heal"):
		health.current_health = health.max_health
		if health.has_method("update_health_bar"):
			health.update_health_bar()

	# Re-enable functionality
	enable_building()

	print(name, " restored and functional!")
