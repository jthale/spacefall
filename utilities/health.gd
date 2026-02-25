extends Node2D

# Health properties
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var destroy_on_death: bool = true  # Whether to queue_free the parent on death

# Health bar visualization
@export var health_bar_sprite: Sprite2D  # The sprite to scale based on health
@export var offset: Vector2 = Vector2(-10, -30)  # Offset from parent in world space

# Signals for other systems to respond to
signal health_changed(new_health: float, max_health: float)
signal damaged(amount: float)
signal died()

var initial_scale: Vector2

func _ready() -> void:
	current_health = max_health
	top_level = true  # Ignore parent's transform

	# Store the initial scale of the health bar sprite
	if health_bar_sprite:
		initial_scale = health_bar_sprite.scale
		update_health_bar()

	# Connect to wave manager for health restoration between waves
	var wave_manager = get_node_or_null("/root/Main/Wave Manager")
	if wave_manager and wave_manager.has_signal("wave_cleared_signal"):
		wave_manager.wave_cleared_signal.connect(_on_wave_cleared)
		print(get_parent().name, " connected to WaveManager for health restoration")
	else:
		print("Warning: ", get_parent().name, " could not find WaveManager at /root/Main/WaveManager")

func _process(_delta: float) -> void:
	# Manually follow parent position with offset
	var parent_node = get_parent()
	if parent_node is Node2D:
		global_position = parent_node.global_position + offset

func update_health_bar() -> void:
	if health_bar_sprite:
		var health_percent = get_health_percent()
		# Scale the X axis to show health remaining
		health_bar_sprite.scale.x = initial_scale.x * health_percent

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return  # Already dead

	current_health -= amount
	current_health = max(0, current_health)  # Clamp to 0

	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	update_health_bar()

	print(get_parent().name, " hit! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	current_health += amount
	current_health = min(current_health, max_health)  # Clamp to max
	health_changed.emit(current_health, max_health)
	update_health_bar()

func die() -> void:
	print(get_parent().name, " destroyed!")
	died.emit()

	if destroy_on_death:
		get_parent().queue_free()

func is_alive() -> bool:
	return current_health > 0

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func _on_wave_cleared() -> void:
	# Restore health to full when wave is cleared
	current_health = max_health
	health_changed.emit(current_health, max_health)
	update_health_bar()
	print(get_parent().name, " health restored to full!")
