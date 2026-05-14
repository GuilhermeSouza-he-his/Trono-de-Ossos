extends Control

# Este código roda quando o botão "JOGAR" é clicado
func _on_jogar_pressed() -> void:
	# MUITO IMPORTANTE: Verifique se o nome do arquivo é word.tscn ou world.tscn
	# Se estiver na pasta scenes, o caminho é esse:
	get_tree().change_scene_to_file("res://intro.tscn")

# Este código roda quando o botão "OPCOES" é clicado
func _on_opcoes_pressed() -> void:
	print("Botão de opções clicado! (Aqui você pode abrir outro menu no futuro)")

# Este código roda quando o botão "SAIR" é clicado
func _on_sair_pressed() -> void:
	get_tree().quit()
