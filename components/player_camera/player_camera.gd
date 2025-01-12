class_name PlayerCamera
extends Camera2D


# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 20.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 30.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 10.0

@onready var rand := RandomNumberGenerator.new()
@onready var noise := FastNoiseLite.new()


# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0

var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	noise.frequency = 2


func _process(delta: float) -> void:
	shake_strength = lerpf(shake_strength, 0, SHAKE_DECAY_RATE * delta)
	self.offset = get_noise_offset(delta)
	if shake_strength < 0.5:
		shake_strength = 0


func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)


func apply_screen_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH
