extends CharacterBody2D

var health := 50
var damaged := false
var direction := 0 # Tambahkan ini jika enemy bisa bergerak

func enemy():
	pass

func _physics_process(delta: float) -> void:
	animation()

func animation():
	if damaged:
		$AnimatedSprite2D.play("Hit") # Ganti dengan animasi hit jika ada
		damaged = false
	elif direction == 0:
		$AnimatedSprite2D.play("Idle")

func take_damage(amount: int) -> void:
	damaged = true
	health -= amount
	print("Enemy health:", health)
	if health <= 0:
		queue_free()
