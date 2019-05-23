extends Piece
class_name Pawn

func _ready():
	pass

func setTeamIndex(teamIndex):
	.setTeamIndex(teamIndex)
	
	$Body.region_rect.position.x = teamIndex * 16
