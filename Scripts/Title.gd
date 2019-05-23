extends Node2D
class_name TitleScreen

func _ready():
	pass

func onStartButtonUp(numberOfPlayers: int):
	Global.numberOfHumanPlayers = numberOfPlayers
	
	get_tree().change_scene("res://Scenes/Game.tscn")
