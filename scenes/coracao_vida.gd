extends TextureRect

<<<<<<< HEAD
const PASTA_SPRITES = "res://assets/sprite life/" 
var frames_coracao = []

func _ready():
	# Carrega de SpriteLife1.png até SpriteLife21.png
	for i in range(1, 22):
		var nome_arquivo = "SpriteLife" + str(i) + ".png"
		var caminho_final = PASTA_SPRITES + nome_arquivo
		var frame = load(caminho_final)
		if frame:
			frames_coracao.append(frame)
		else:
			push_error("Erro ao carregar: " + caminho_final)
	
	if frames_coracao.size() > 0:
		texture = frames_coracao[0] # Começa cheio

func atualizar_vida(vida_atual: float, vida_maxima: float):
	if frames_coracao.size() == 0: return
	
	var porcentagem = clamp(vida_atual / vida_maxima, 0.0, 1.0)
	
	# Inverte o índice: 1.0 (cheio) vira índice 0
	# 0.0 (vazio) vira o último índice da lista
	var total_frames = frames_coracao.size()
	var indice = int((1.0 - porcentagem) * (total_frames - 1))
	indice = clamp(indice, 0, total_frames - 1)
=======
# 
const PASTA_SPRITES = "res://assets/sprite life/" 

var frames_coracao = []

func _ready():
	# carregar os 22 arquivos
	for i in range(22):
		var nome_arquivo = ""
		if i == 0:
			nome_arquivo = "Sprite life.png"
		else:
			nome_arquivo = "SpriteLife" + str(i) + ".png"
		
		var caminho = PASTA_SPRITES + nome_arquivo
		
		
		if FileAccess.file_exists(caminho):
			frames_coracao.append(load(caminho))
		else:
			print("Erro: Arquivo não encontrado em: ", caminho)

	# 
	if frames_coracao.size() > 0:
		texture = frames_coracao[0]
	else:
		print("Erro Crítico: Nenhum sprite foi carregado em frames_coracao!")

func atualizar_vida(vida_atual: float, vida_maxima: float):
	if frames_coracao.size() == 0: return
	if vida_maxima <= 0: return
	
	var porcentagem = clamp(vida_atual / vida_maxima, 0.0, 1.0)
	var indice = int((1.0 - porcentagem) * (frames_coracao.size() - 1))
	indice = clamp(indice, 0, frames_coracao.size() - 1)
>>>>>>> 566e3afaee1913f90c2a2904506d1917d80b4620
	
	texture = frames_coracao[indice]
