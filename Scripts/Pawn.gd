extends BoardCellContent
class_name Pawn

func _ready():
	pass

func initialize():
	.initialize()
	
	movementRange = 1
	canAttack = false
	canUsePieces = false

func setTeamIndex(teamIndex):
	.setTeamIndex(teamIndex)
	
	$Body.region_rect.position.x = teamIndex * 16
