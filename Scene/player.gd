extends CharacterBody2D

@export var speed: float = 200.0
@export var attack_dash_speed: float = 400.0
@export var combo_dash_speed: float = 700.0
var last_direction := 1
var health := 100

var attack_cooldown := 0.7
var attack_cooldown_timer := 0.0
var attack_duration := 0.3
var attack_duration_timer := 0.0
@onready var attack_sound = $AttackSFX
@onready var combo_sound = $ComboSFX
var combo_ready := false
var is_combo_attacking := false

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_shape_horizontal = $Attack/CollisionShape2D
@onready var attack_shape_vertical = $Attack/CollisionShape2D2
@onready var combo_shape_horizontal = $Combo/CollisionShape2D
@onready var combo_shape_vertical = $Combo/CollisionShape2D2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var input_vector = _get_input_vector()
	_update_timers(delta)
	_process_attack(input_vector)
	_update_animation(input_vector)
	_update_direction(input_vector)
	
	if not _is_attacking():
		velocity = input_vector * speed
	move_and_slide()

func _update_timers(delta: float) -> void:
	attack_cooldown_timer = max(attack_cooldown_timer - delta, 0.0)
	attack_duration_timer = max(attack_duration_timer - delta, 0.0)

func _get_input_vector() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

func _process_attack(input_vector: Vector2) -> void:
	var is_attack_pressed = Input.is_action_just_pressed("attack")
	var attacking = false
	var combo_attacking = false

	if is_attack_pressed and attack_cooldown_timer <= 0.0 and not _is_attacking():
		_start_attack(input_vector)
		attacking = true
		combo_ready = true
	elif is_attack_pressed and _is_attacking() and combo_ready:
		_start_combo(input_vector)
		attacking = true
		combo_attacking = true
		combo_ready = false
	elif _is_attacking():
		attacking = true
		combo_attacking = is_combo_attacking

	# Enable/disable attack and combo shapes
	attack_shape_horizontal.disabled = not (attacking and not combo_attacking)
	attack_shape_vertical.disabled = not (attacking and not combo_attacking)
	combo_shape_horizontal.disabled = not (attacking and combo_attacking)
	combo_shape_vertical.disabled = not (attacking and combo_attacking)

func _start_attack(input_vector: Vector2) -> void:
	is_combo_attacking = false
	animated_sprite.play("Attack")
	attack_duration_timer = attack_duration
	attack_cooldown_timer = attack_cooldown
	velocity = _get_attack_velocity(input_vector)
	print("attack dash enabled")
	attack_sound.play()

func _start_combo(input_vector: Vector2) -> void:
	is_combo_attacking = true
	animated_sprite.play("Combo")
	attack_duration_timer = attack_duration
	attack_cooldown_timer = attack_cooldown
	velocity = _get_combo_velocity(input_vector)
	print("combo dash enabled")
	combo_sound.play()

func _get_attack_velocity(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		input_vector = Vector2(last_direction, 0)
	return input_vector.normalized() * attack_dash_speed

func _get_combo_velocity(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		input_vector = Vector2(last_direction, 0)
	return input_vector.normalized() * combo_dash_speed
	

func _is_attacking() -> bool:
	return attack_duration_timer > 0.0

func _update_animation(input_vector: Vector2) -> void:
	if _is_attacking():
		animated_sprite.play("Combo" if is_combo_attacking else "Attack")
	elif input_vector == Vector2.ZERO:
		animated_sprite.play("Idle")
	else:
		animated_sprite.play("Run")

func _update_direction(input_vector: Vector2) -> void:
	if abs(input_vector.x) > 0.1:
		last_direction = sign(input_vector.x)
	animated_sprite.flip_h = last_direction < 0
	$Attack.scale.x = last_direction
	$Combo.scale.x = last_direction

func _on_attack_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(10)

func _on_combo_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(5)
