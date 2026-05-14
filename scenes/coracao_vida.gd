extends TextureRect

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
	
	texture = frames_coracao[indice]
