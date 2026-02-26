extends Node

# Signal emitted when credits change (for UI updates)
signal credits_changed(new_amount: int)

# Current credits
var credits: int = 3

func _ready():
	print("Economy: Starting with %d credits" % credits)

# Add credits (from wave completion, building income, etc.)
func add_credits(amount: int) -> void:
	credits += amount
	print("Economy: +%d credits. Total: %d" % [amount, credits])
	credits_changed.emit(credits)

# Attempt to spend credits (returns true if successful)
func spend(amount: int) -> bool:
	if can_afford(amount):
		credits -= amount
		print("Economy: -%d credits. Total: %d" % [amount, credits])
		credits_changed.emit(credits)
		return true
	else:
		print("Economy: Cannot afford %d credits. Current: %d" % [amount, credits])
		return false

# Check if player can afford a cost
func can_afford(amount: int) -> bool:
	return credits >= amount

# Get current credits
func get_credits() -> int:
	return credits

# Set credits directly (useful for debugging or save/load)
func set_credits(amount: int) -> void:
	credits = amount
	credits_changed.emit(credits)
