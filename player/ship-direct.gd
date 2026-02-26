extends Area2D

# Ship movement properties
@export var acceleration: float = 400.0  # Acceleration in desired direction
@export var max_speed: float = 300.0     # Maximum ship speed
@export var drag: float = 0.95           # Velocity decay per frame (0.95 = 5% drag)

# Current velocity
var velocity: Vector2 = Vector2.ZERO

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
