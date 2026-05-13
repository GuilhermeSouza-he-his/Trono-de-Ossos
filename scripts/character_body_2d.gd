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
@export var vida_max = 22.0 
@export var escudo_max = 5.0

var vida_atual: float
var escudo_atual: float

@onready var barra_vida = get_node("/root/word/CanvasLayer/TextureRect/VBoxContainer/CoracaoVida")
@onready var barra_escudo = get_node("/root/word/CanvasLayer/TextureRect/VBoxContainer/ProgressBarEscudo")

func _ready():
	vida_atual = vida_max
	escudo_atual = escudo_max
	atualizar_hud()
	
func tomar_dano(amount: float):
	if is_dead: return

	if escudo_atual > 0:
		escudo_atual -= amount
		if escudo_atual < 0:
			vida_atual += escudo_atual
			escudo_atual = 0
	else:
		vida_atual -= amount

	atualizar_hud()

	if vida_atual <= 0:
		vida_atual = 0
		die()

func atualizar_hud():
	if barra_vida and barra_vida.has_method("atualizar_vida"):
		barra_vida.atualizar_vida(vida_atual, vida_max)
	
	if barra_escudo:
		barra_escudo.max_value = escudo_max
		barra_escudo.value = escudo_atual

func _input(_event):
	if Input.is_action_just_pressed("equip"):
		esta_armado = !esta_armado
		print("Espada equipada: ", esta_armado)
	
	if Input.is_key_pressed(KEY_K):
		tomar_dano(1)

func _physics_process(_delta):
	if is_dead: return

	match current_state:
		State.IDLE: idle_state()
		State.MOVE: move_state()
		State.ATTACK: attack_state()
		State.JUMP: jump_state()

# --- FUNÇÃO DE ANIMAÇÃO COM SUPORTE TEMPORÁRIO ---
func tocar_animacao(nome_base: String):
	var prefixo = ""
	
	if esta_armado:
		# APENAS ATAQUE USA PREFIXO ATUALMENTE
		if nome_base == "slash":
			prefixo = "sword_"
		
		# --- BLOCO COMENTADO (REATIVAR QUANDO OS SPRITES ESTIVEREM PRONTOS) ---
		# elif nome_base == "idle" or nome_base == "run" or nome_base == "walk":
		# 	prefixo = "sword_"
		# ---------------------------------------------------------------------
	
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
		tocar_animacao("slash") 
		
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
	if is_dead: return 
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO
	
	animations.play("death")
	print("O personagem morreu!")

	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()

func return_to_idle(_anim = ""):
	current_state = State.IDLE
