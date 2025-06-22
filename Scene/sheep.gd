extends CharacterBody2D

var health := 50
var damaged := false
var direction := Vector2.ZERO
var speed := 50
var change_direction_time := 1.0
var direction_timer := 0.0
var is_eating := false

func _physics_process(delta: float) -> void:
	direction_timer -= delta
	if direction_timer <= 0.0:
		randomize_direction()
		direction_timer = change_direction_time
	velocity = direction * speed
	move_and_slide()
	animation()

func randomize_direction():
	if randi_range(0, 1) == 0:
		direction = Vector2.ZERO
		is_eating = false
	elif randi_range(0,3) == 0:
		direction = Vector2.ZERO
		is_eating = true
	else:
		var angle = randf() * TAU
		direction = Vector2(cos(angle), sin(angle)).normalized()
		is_eating = false

func animation():
	if damaged:
		$AnimatedSprite2D.play("Hit")
		damaged = false
	elif direction == Vector2.ZERO:
		if is_eating:
			$AnimatedSprite2D.play("Eat")
		else:
			$AnimatedSprite2D.play("Idle")
	else:
		$AnimatedSprite2D.play("Walk")
		if direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true

func take_damage(amount: int) -> void:
	damaged = true
	health -= amount
	print("Random Entity health:", health)
	if health <= 0:
		queue_free()
