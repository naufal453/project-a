extends Node2D

@onready var sheep_sound = $sheep_sound
var sheep_timer := 0.0
var sheep_interval := 3.0

func _process(delta: float) -> void:
	sheep_timer -= delta
	if sheep_timer <= 0.0:
		sheep_sound.play()
		sheep_timer = sheep_interval

func _on_sheep_sound_finished() -> void:
	pass # Replace with function body.
