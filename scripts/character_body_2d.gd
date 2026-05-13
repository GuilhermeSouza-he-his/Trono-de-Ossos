extends CharacterBody2D

@export var speed_walk = 110.0
@export var speed_run = 190.0
@export var jump_force = 150.0

@onready var animations = find_child("AnimatedSprite2D")



var last_direction = "baixo"
var is_dead = false
var esta_armado = false 

enum State { IDLE, MOVE, ATTACK, PARRY, JUMP, DEAD }
var current_state = State.IDLE

# --- SISTEMA DE VIDA E ESCUDO ---
@export var vida_max = 6.0
@export var escudo_max = 5.0

var vida_atual: float
var escudo_atual: float

# Arraste as suas ProgressBars da aba Scene para aqui segurando CTRL para pegar o caminho correto
@onready var barra_vida = get_node("/root/word/CanvasLayer/TextureRect/VBoxContainer/ProgressBarVida")
@onready var barra_escudo = get_node("/root/word/CanvasLayer/TextureRect/VBoxContainer/ProgressBarEscudo")

func _ready():
	vida_atual = vida_max
	escudo_atual = escudo_max
	atualizar_hud()
	
func tomar_dano(quantidade: float):
	if is_dead: return

	# Lógica: O escudo absorve o dano primeiro
	if escudo_atual > 0:
		escudo_atual -= quantidade
		if escudo_atual < 0:
			# Se o dano foi maior que o escudo, o resto vai para a vida
			vida_atual += escudo_atual
			escudo_atual = 0
	else:
		vida_atual -= quantidade

	atualizar_hud()

	if vida_atual <= 0:
		vida_atual = 0
		die()

func atualizar_hud():
	if barra_vida:
		barra_vida.max_value = vida_max
		barra_vida.value = vida_atual
	if barra_escudo:
		barra_escudo.max_value = escudo_max
		barra_escudo.value = escudo_atual

func _input(_event):
	if Input.is_action_just_pressed("equip"):
		esta_armado = !esta_armado
		print("Espada equipada: ", esta_armado)
	if Input.is_key_pressed(KEY_K): # Pressionar a tecla K para testar dano
		tomar_dano(1)

func _physics_process(_delta):
	if is_dead: return

	match current_state:
		State.IDLE: idle_state()
		State.MOVE: move_state()
		State.ATTACK: attack_state()
		State.JUMP: jump_state()

# --- ESSA FUNÇÃO RESOLVE O PROBLEMA VISUAL ---
func tocar_animacao(nome_base: String):
	var prefixo = ""
	if esta_armado:
		prefixo = "sword_" # Adiciona "sword_" se estiver armado
	
	# Exemplo: vira "sword_walk_baixo" ou apenas "walk_baixo"
	animations.play(prefixo + nome_base + "_" + last_direction)

func idle_state():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		current_state = State.MOVE
		return
	
	check_actions()
	velocity = Vector2.ZERO
	tocar_animacao("idle") 
	move_and_slide()

func move_state():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction == Vector2.ZERO:
		current_state = State.IDLE
		return

	var is_running = Input.is_key_pressed(KEY_SHIFT)
	velocity = direction * (speed_run if is_running else speed_walk)
	
	update_last_direction(direction)
	tocar_animacao("run" if is_running else "walk")
	
	check_actions()
	move_and_slide()

func attack_state():
	if esta_armado:
		velocity = Vector2.ZERO
		tocar_animacao("slash") # Vai tocar "sword_slash_direcao"
		
		if not animations.animation_finished.is_connected(return_to_idle):
			animations.animation_finished.connect(return_to_idle, CONNECT_ONE_SHOT)
	else:
		current_state = State.IDLE

func jump_state():
	var jump_vec = Vector2.ZERO
	match last_direction:
		"cima": jump_vec = Vector2.UP
		"baixo": jump_vec = Vector2.DOWN
		"esquerda": jump_vec = Vector2.LEFT
		"direita": jump_vec = Vector2.RIGHT
	
	velocity = jump_vec * jump_force
	tocar_animacao("jump")
	
	move_and_slide()
	await get_tree().create_timer(0.4).timeout
	return_to_idle()

func check_actions():
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK
	elif Input.is_action_just_pressed("ui_select"):
		current_state = State.JUMP

func update_last_direction(direction):
	if direction.x > 0: last_direction = "direita"
	elif direction.x < 0: last_direction = "esquerda"
	elif direction.y > 0: last_direction = "baixo"
	elif direction.y < 0: last_direction = "cima"

func die():
	if is_dead: return # Evita rodar a lógica duas vezes
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO
	
	# Toca a animação 'death' que você criou no AnimatedSprite2D
	animations.play("death")
	
	print("O personagem morreu!")

	# Opcional: Reiniciar a cena após 3 segundos
	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()

func return_to_idle(_anim = ""):
	current_state = State.IDLE
	
	
