extends Node2D
class_name Piece

export(int) var teamIndex = 0

func _ready():
	setTeamIndex(teamIndex)

func setTeamIndex(teamIndex):
	self.teamIndex = teamIndex
	
	$Sprite.region_rect.position.x = teamIndex * 16

#func get
