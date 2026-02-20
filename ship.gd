extends Node2D

# Ship movement properties
@export var acceleration: float = 200.0  # Acceleration when pressing W
@export var max_speed: float = 300.0     # Maximum ship speed
@export var rotation_speed: float = 3.0  # Rotation speed in radians/second
@export var drag: float = 0.98          # Velocity decay per frame (0.98 = 2% drag)

# Current velocity
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Handle rotation (A and D keys)
	var rotation_input: float = 0.0
	if Input.is_action_pressed("ui_left"):  # A key
		rotation_input -= 1.0
	if Input.is_action_pressed("ui_right"):  # D key
		rotation_input += 1.0

	# Apply rotation
	rotation += rotation_input * rotation_speed * delta

	# Handle acceleration (W and S keys)
	var thrust_input: float = 0.0
	if Input.is_action_pressed("ui_up"):  # W key
		thrust_input += 1.0
	if Input.is_action_pressed("ui_down"):  # S key
		thrust_input -= 1.0

	# Calculate forward direction based on current rotation
	var forward_direction: Vector2 = Vector2.RIGHT.rotated(rotation)

	# Apply acceleration in the forward direction
	if thrust_input != 0.0:
		velocity += forward_direction * thrust_input * acceleration * delta

	# Apply drag to simulate space friction
	velocity *= drag

	# Clamp velocity to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Move the ship
	position += velocity * delta
