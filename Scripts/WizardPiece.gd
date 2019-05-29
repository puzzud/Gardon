extends Piece
class_name WizardPiece

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
	var enemyWizard: Wizard = boardCellContent.getEnemyWizard()
	if enemyWizard == null:
		if $AnimationPlayer.has_animation("idleDown"):
			$AnimationPlayer.play("idleDown")
		return
	
	var enemyWizardPiece = enemyWizard.piece
	
	var directionToEnemyWizard = Global.getDirectionFromVector(enemyWizardPiece.global_position - global_position)

	var animationName = "idle" + getAnimationNameSuffixFromMovementDirection(directionToEnemyWizard)
	if $AnimationPlayer.has_animation(animationName):
		$AnimationPlayer.play(animationName)
