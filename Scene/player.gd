extends CharacterBody2D

@export var speed: float = 200.0
var last_horizontal_direction: int = 1
var last_vertical_direction: int = 1
var random_entity_inattack_range = false
var random_entity_attack_cooldown = true
var health = 100
var player_alive = true
var attack_cooldown_time := 1.0 # seconds
var attack_cooldown_timer := 0.0
var attack_duration_time := 0.3 # seconds the attack is active
var attack_duration_timer := 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area_horizontal = $AttackHorizontal
@onready var attack_shape_horizontal = $AttackHorizontal/CollisionShape2D
@onready var attack_area_vertical = $AttackVertical
@onready var attack_shape_vertical = $AttackVertical/CollisionShape2D

func _physics_process(delta: float) -> void:
	var input_vector := get_input_vector()

	# Update attack cooldown timer
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	# Update attack duration timer
	if attack_duration_timer > 0.0:
		attack_duration_timer -= delta

	handle_attack()
	play_animation(input_vector)
	update_direction(input_vector)
	random_entity_attack()
	# Move only if not attacking
	if not Input.is_action_pressed("attack"):
		velocity = input_vector * speed
		move_and_slide()

func get_input_vector() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

func handle_attack() -> void:
	if Input.is_action_pressed("attack") and attack_cooldown_timer <= 0.0:
		animated_sprite.play("Attack")
		attack_duration_timer = attack_duration_time # Start attack duration
		attack_cooldown_timer = attack_cooldown_time # Start cooldown

	# Enable attack shapes only during attack duration
	if attack_duration_timer > 0.0:
		attack_shape_horizontal.disabled = false
		attack_shape_vertical.disabled = false
	else:
		attack_shape_horizontal.disabled = true
		attack_shape_vertical.disabled = true

func play_animation(input_vector: Vector2) -> void:
	if attack_duration_timer > 0.0:
		# Attack animation is active during attack duration
		if animated_sprite.animation != "Attack":
			animated_sprite.play("Attack")
		return
	elif attack_cooldown_timer > 0.0 and input_vector == Vector2.ZERO:
		# During cooldown but not attacking, play idle
		animated_sprite.play("Idle")
	elif input_vector == Vector2.ZERO:
		animated_sprite.play("Idle")
	else:
		animated_sprite.play("Run")

func update_direction(input_vector: Vector2) -> void:
	if abs(input_vector.x) > 0.1:
		last_horizontal_direction = sign(input_vector.x)
	#elif abs(input_vector.y) >0.1:
		#last_vertical_direction = sign(input_vector.y)
	animated_sprite.flip_h = last_horizontal_direction < 0
	attack_area_horizontal.scale.x = last_horizontal_direction
	#attack_area_vertical.scale.y = last_vertical_direction


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		random_entity_inattack_range=false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		random_entity_inattack_range = true

func _on_attack_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(20) # Adjust damage as needed
		#print("aduh")

func _on_attack_horizontal_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(20)
		print("Hit horizontal")

func _on_attack_vertical_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(20)
		print("Hit vertical")

func random_entity_attack():
	if random_entity_inattack_range:
		print("gedebuk")

func player():
	pass
