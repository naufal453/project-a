extends Node2D


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/world.tscn")
	#pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
	#pass # Replace with function body.


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/options.tscn") # Replace with function body.
