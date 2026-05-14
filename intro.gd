extends Control

func _ready():
	# Inicia a animação assim que a cena carrega
	$AnimationPlayer.play("historia")

# Esta função será chamada AUTOMATICAMENTE pelo sinal que conectamos
func _on_animation_player_animation_finished(anim_name):
	ir_para_o_jogo()

func _input(event):
	# Opcional: Se o jogador clicar, ele pode PULAR a intro antes dela acabar
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			ir_para_o_jogo()

func ir_para_o_jogo():
	# Ajuste o caminho para a sua cena de jogo real
<<<<<<< HEAD
	get_tree().change_scene_to_file("res://scenes/world_test.tscn")
=======
	get_tree().change_scene_to_file("res://scenes/world.tscn")
>>>>>>> 566e3afaee1913f90c2a2904506d1917d80b4620
