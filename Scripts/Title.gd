extends Node2D
class_name TitleScreen

func _ready():
	pass

func onStartButtonUp(numberOfHumanPlayers: int):
	Global.numberOfHumanPlayers = numberOfHumanPlayers
	
	for i in range(0, Global.MaximumNumberOfPlayers):
		Global.playerTypes[i] = Global.PlayerType.COMPUTER
	
	if numberOfHumanPlayers > 0:
		for i in range(0, numberOfHumanPlayers):
			Global.playerTypes[i] = Global.PlayerType.HUMAN
	
	get_tree().change_scene("res://Scenes/Game.tscn")
