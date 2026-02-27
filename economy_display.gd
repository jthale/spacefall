extends Control

# Reference to the label that displays credits
@onready var credits_label: Label = $Credits

func _ready():
	# Connect to Economy's credits_changed signal
	Economy.credits_changed.connect(_on_credits_changed)

	# Set initial display
	update_display(Economy.get_credits())

func _on_credits_changed(new_amount: int) -> void:
	update_display(new_amount)

func update_display(amount: int) -> void:
	if credits_label:
		credits_label.text = "%d C" % amount
