extends CharacterBody2D

# --- CONFIGURAÇÕES ---
@export var speed_walk = 110.0
@export var speed_run = 190.0
@export var dano_ataque = 5.0

@onready var animations = find_child("AnimatedSprite2D")
@onready var area_ataque = $AreaAtaque
@onready var shape_ataque = $AreaAtaque/CollisionShape2D

# Referências da HUD (Ajuste o caminho se necessário)
@onready var barra_vida = get_node_or_null("/root/word/bar_life_shield/CanvasLayer/TextureRect/VBoxContainer/ProgressBarVida")
@onready var barra_escudo = get_node_or_null("/root/word/bar_life_shield/CanvasLayer/TextureRect/VBoxContainer/ProgressBarEscudo")

# --- ESTADOS E CONTROLE ---
var last_direction = "baixo"
var is_dead = false
var esta_armado = false 
var ja_causou_dano = false # Impede que o inimigo morra com um só clique

enum State { IDLE, MOVE, ATTACK, DEAD }
var current_state = State.IDLE

@export var vida_max = 10.0
@export var escudo_max = 5.0
var vida_atual: float
var escudo_atual: float

func _ready():
	vida_atual = vida_max
	escudo_atual = escudo_max
	atualizar_hud()

func _physics_process(_delta):
	if is_dead: return
	
	match current_state:
		State.IDLE: idle_state()
		State.MOVE: move_state()
		State.ATTACK: attack_state()

func _input(_event):
	if is_dead: return
	if Input.is_action_just_pressed("equip"):
		esta_armado = !esta_armado
	if Input.is_key_pressed(KEY_K): # Teste de dano no player
		tomar_dano(1)

# --- ESTADOS DE MOVIMENTO ---

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

# --- LÓGICA DE COMBATE ---

func attack_state():
	if esta_armado:
		velocity = Vector2.ZERO
		tocar_animacao("slash") 
		
		# Sincroniza o dano: só causa dano UMA vez por animação
		if not ja_causou_dano:
			posicionar_hitbox_ataque()
			causar_dano_nos_inimigos()
			ja_causou_dano = true 
		
		if not animations.animation_finished.is_connected(return_to_idle):
			animations.animation_finished.connect(return_to_idle, CONNECT_ONE_SHOT)
	else:
		current_state = State.IDLE

func causar_dano_nos_inimigos():
	var corpos = area_ataque.get_overlapping_bodies()
	for corpo in corpos:
		if corpo.has_method("tomar_dano") and corpo != self:
			corpo.tomar_dano(dano_ataque)

func posicionar_hitbox_ataque():
	match last_direction:
		"direita": area_ataque.position = Vector2(36, 0)
		"esquerda": area_ataque.position = Vector2(-36, 0)
		"baixo": area_ataque.position = Vector2(0, 25)
		"cima": area_ataque.position = Vector2(0, -25)

func tomar_dano(quantidade: float):
	if is_dead: return
	if escudo_atual > 0:
		escudo_atual -= quantidade
		if escudo_atual < 0:
			vida_atual += escudo_atual
			escudo_atual = 0
	else:
		vida_atual -= quantidade
	atualizar_hud()
	if vida_atual <= 0: die()

# --- AUXILIARES ---

func atualizar_hud():
	if barra_vida: barra_vida.value = vida_atual
	if barra_escudo: barra_escudo.value = escudo_atual

func tocar_animacao(nome_base: String):
	var prefixo = "sword_" if esta_armado else ""
	animations.play(prefixo + nome_base + "_" + last_direction)

func update_last_direction(direction):
	if direction.x > 0: last_direction = "direita"
	elif direction.x < 0: last_direction = "esquerda"
	elif direction.y > 0: last_direction = "baixo"
	elif direction.y < 0: last_direction = "cima"

func check_actions():
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK

func return_to_idle(_anim = ""):
	ja_causou_dano = false # Reseta para o próximo ataque
	current_state = State.IDLE
	area_ataque.position = Vector2(-1, 0)

func die():
	if is_dead: return 
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO
	animations.play("death")
	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()
