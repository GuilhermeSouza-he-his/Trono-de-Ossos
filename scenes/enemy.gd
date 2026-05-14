extends CharacterBody2D

@export var vida_maxima: float = 20 
var vida_atual: float
var is_dead = false

@onready var animations = $AnimatedSprite2D 

func _ready():
	vida_atual = vida_maxima

func tomar_dano(quantidade: float):
	if is_dead: return
	
	vida_atual -= quantidade
	print("Inimigo recebeu dano! Vida: ", vida_atual)
	
	if vida_atual <= 0:
		die()
	else:
		# Verifica se existe animação de 'hurt' antes de tocar
		if animations.sprite_frames.has_animation("hurt"):
			animations.play("hurt")

func die():
	if is_dead: return 
	is_dead = true
	velocity = Vector2.ZERO
	
	# Correção: Acessa sprite_frames para verificar animação
	if animations.sprite_frames.has_animation("death"):
		animations.play("death")
	
	print("O inimigo morreu!")

	# Reinicia apenas o inimigo ou a cena após 5 segundos
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()
