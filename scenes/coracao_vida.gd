extends TextureRect

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
	
	texture = frames_coracao[indice]
