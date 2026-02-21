extends Node2D

# Ship movement properties
@export var acceleration: float = 200.0  # Acceleration when pressing direction
@export var max_speed: float = 300.0     # Maximum ship speed
@export var drag: float = 0.98          # Velocity decay per frame (0.98 = 2% drag)
@export var rotation_speed: float = 9.0  # Rotation speed in radians/second

# Current velocity
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1.0
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1.0

	# Normalize input to prevent faster diagonal movement
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	# Apply acceleration in the input direction
	if input_direction.length() > 0:
		velocity += input_direction * acceleration * delta

	# Apply drag to simulate space friction
	velocity *= drag

	# Clamp velocity to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Rotate ship to face velocity direction
	if velocity.length() > 10.0:  # Only rotate if moving
		var target_rotation = velocity.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Move the ship
	position += velocity * delta
