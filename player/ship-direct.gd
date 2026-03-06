extends Area2D

# Ship movement properties
@export var acceleration: float = 400.0  # Acceleration in desired direction
@export var max_speed: float = 300.0     # Maximum ship speed
@export var drag: float = 0.95           # Velocity decay per frame (0.95 = 5% drag)

# Current velocity
var velocity: Vector2 = Vector2.ZERO

# Reference to health component
@onready var health = $Health

func _ready() -> void:
	# Connect to health died signal
	if health and health.has_signal("died"):
		health.died.connect(_on_ship_died)

func _on_ship_died() -> void:
	# Disable ship processing
	set_physics_process(false)

	# Disable collision
	collision_layer = 0
	collision_mask = 0

	# Remove from player group so enemies stop targeting
	remove_from_group("player")

	# Disable all child nodes (laser, etc.)
	for child in get_children():
		if child != health:  # Keep health active for respawn logic
			child.process_mode = Node.PROCESS_MODE_DISABLED

func enable_ship() -> void:
	# Re-enable ship processing
	set_physics_process(true)

	# Re-enable collision (restore default values)
	collision_layer = 1
	collision_mask = 2

	# Add back to player group so enemies can target
	add_to_group("player")

	# Re-enable all child nodes
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_INHERIT

	# Reset velocity
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Get input direction from keyboard/gamepad
	var input_direction: Vector2 = Input.get_vector(
		"ui_left",   # Left
		"ui_right",  # Right
		"ui_up",     # Up
		"ui_down"    # Down
	)

	# If there's input, instantly rotate to face that direction and accelerate
	if input_direction.length() > 0.0:
		# Instantly rotate ship to face input direction
		# Add PI/2 to account for ship sprite pointing up
		rotation = input_direction.angle() + PI / 2

		# Apply acceleration in the input direction
		velocity += input_direction.normalized() * acceleration * delta

	# Apply drag to simulate space friction
	velocity *= drag

	# Clamp velocity to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Move the ship
	position += velocity * delta
