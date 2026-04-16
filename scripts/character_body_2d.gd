extends CharacterBody2D

@export var speed_walk = 110.0
@export var speed_run = 190.0

@onready var animations = find_child("AnimatedSprite2D")


var last_direction = "baixo"

func _physics_process(_delta):
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
	var is_running = Input.is_key_pressed(KEY_SHIFT)
	var current_speed = speed_run if is_running else speed_walk

	
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		
		
		if direction.x > 0:
			last_direction = "direita"
		elif direction.x < 0:
			last_direction = "esquerda"
		elif direction.y > 0:
			last_direction = "baixo"
		elif direction.y < 0:
			last_direction = "cima"
		
		
		var action = "run_" if is_running else "walk_"
		animations.play(action + last_direction)
	else:
	
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
		animations.play("idle_" + last_direction)

	move_and_slide()
