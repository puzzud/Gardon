extends Piece
class_name Wizard

const bodyTextureTeam0 = preload("res://Assets/Sprites/FarmerOrange.tres")
const bodyTextureTeam1 = preload("res://Assets/Sprites/FarmerRed.tres")

func _ready():
	pass

func setTeamIndex(teamIndex: int):
	.setTeamIndex(teamIndex)
	
	if teamIndex == 0:
		$Body.texture = bodyTextureTeam0
	else:
		$Body.texture = bodyTextureTeam1

func onDeactivationFinished():
	faceEnemyWizard()

func faceEnemyWizard():
	var enemyWizard := getEnemyWizard()
	if enemyWizard == null:
		if $AnimationPlayer.has_animation("idleDown"):
			$AnimationPlayer.play("idleDown")
		return
	
	var directionToEnemyWizard = Global.getDirectionFromVector(enemyWizard.global_position - global_position)
	
	var animationName = "idle" + getAnimationNameSuffixFromMovementDirection(directionToEnemyWizard)
	if $AnimationPlayer.has_animation(animationName):
		$AnimationPlayer.play(animationName)

func getEnemyWizard() -> Wizard:
	var enemyWizards := []
	
	for enemyTeamIndex in Global.game.getEnemyTeamIndices(boardCellContent.teamIndex):
		enemyWizards = enemyWizards + Global.game.getWizardsFromTeamIndex(enemyTeamIndex)
	
	if enemyWizards.empty():
		return null
	
	# Assume maximum of only one wizard per team.
	return enemyWizards.front()
