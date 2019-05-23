extends Piece
class_name Wizard

func _ready():
	pass

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
	
	for enemyTeamIndex in Global.game.getEnemyTeamIndices(teamIndex):
		enemyWizards = enemyWizards + Global.game.getWizardsFromTeamIndex(enemyTeamIndex)
	
	if enemyWizards.empty():
		return null
	
	# Assume maximum of only one wizard per team.
	return enemyWizards.front()
