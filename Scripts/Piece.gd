extends Node2D
class_name Piece

export(int) var teamIndex = 0

var activated: bool = false

func _ready():
	setTeamIndex(teamIndex)

func setTeamIndex(teamIndex):
	self.teamIndex = teamIndex
	
	$Body.region_rect.position.x = teamIndex * 16

func setActivated(activated: bool):
	self.activated = activated
	
	if activated:
		$AnimationPlayer.play("activate")
	else:
		$AnimationPlayer.play("deactivate")
