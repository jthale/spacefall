extends Node

# Signals
signal wave_cleared_signal

# Configuration
@export_file("*.json") var waves_json_path: String = ""
@export var spawn_point: Marker2D = null  # Set in inspector

# Enemy scene mapping (add new enemy types here)
var enemy_scenes: Dictionary = {
	"small": preload("res://enemy/enemy_small.tscn"),
	"chaser": preload("res://enemy/enemy_chase.tscn"),
}

# State
var waves: Array = []
var current_wave_index: int = 0
var enemies_remaining: int = 0
var is_spawning: bool = false

func _ready() -> void:
	if waves_json_path != "":
		load_waves()
	else:
		push_warning("WaveManager: No waves JSON file set!")

	if spawn_point == null:
		push_warning("WaveManager: No spawn point set!")

	# Auto-start first wave (you can change this to manual start)
	# start_next_wave()  # Disabled - using manual button start

func load_waves() -> void:
	var file = FileAccess.open(waves_json_path, FileAccess.READ)

	if file == null:
		push_error("WaveManager: Could not open waves file at %s" % waves_json_path)
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("WaveManager: JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return

	var data = json.get_data()

	if data is Dictionary and data.has("waves"):
		waves = data.waves
		print("WaveManager: Loaded %d waves" % waves.size())
	else:
		push_error("WaveManager: Invalid JSON format - expected 'waves' array")

func start_next_wave() -> void:
	if is_spawning:
		push_warning("WaveManager: Already spawning a wave!")
		return

	if current_wave_index >= waves.size():
		print("WaveManager: All waves completed!")
		wave_all_completed()
		return

	var wave = waves[current_wave_index]
	print("WaveManager: Starting wave %d" % (current_wave_index + 1))

	current_wave_index += 1
	spawn_wave(wave)

func spawn_wave(wave: Dictionary) -> void:
	if spawn_point == null:
		push_error("WaveManager: Cannot spawn - no spawn point set!")
		return

	is_spawning = true

	# Spawn all enemies at once
	if wave.has("enemies"):
		for enemy_group in wave.enemies:
			var enemy_type = enemy_group.get("type", "small")
			var count = enemy_group.get("count", 1)

			for i in range(count):
				spawn_enemy(enemy_type)

	is_spawning = false
	print("WaveManager: Wave %d spawned. %d enemies active." % [current_wave_index, enemies_remaining])

func spawn_enemy(type: String) -> void:
	if not enemy_scenes.has(type):
		push_error("WaveManager: Unknown enemy type '%s'" % type)
		return

	var enemy_scene = enemy_scenes[type]
	var enemy = enemy_scene.instantiate()

	# Set spawn position
	enemy.position = spawn_point.global_position

	# Add to scene (deferred to avoid blocking during _ready)
	get_parent().call_deferred("add_child", enemy)

	# Track enemy count
	enemies_remaining += 1
	enemy.tree_exited.connect(_on_enemy_died)

	print("WaveManager: Spawned %s enemy at %s" % [type, spawn_point.global_position])

func _on_enemy_died() -> void:
	enemies_remaining -= 1
	print("WaveManager: Enemy died. %d remaining." % enemies_remaining)

	if enemies_remaining <= 0 and not is_spawning:
		wave_cleared()

func wave_cleared() -> void:
	print("WaveManager: Wave %d cleared!" % current_wave_index)

	# Emit signal for health restoration and other wave-cleared effects
	wave_cleared_signal.emit()

	# Optional: Wait before starting next wave
	# await get_tree().create_timer(3.0).timeout
	# start_next_wave()

func wave_all_completed() -> void:
	print("WaveManager: All waves completed! Victory!")
	# You can emit a signal here or trigger victory screen

# Manual control functions
func start_wave_manually(wave_index: int = 0) -> void:
	current_wave_index = wave_index
	start_next_wave()

func get_current_wave() -> int:
	return current_wave_index

func get_total_waves() -> int:
	return waves.size()


func _on_start_wave_button_pressed() -> void:
	start_next_wave()
