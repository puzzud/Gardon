extends BoardCellContent
class_name Wizard

func _ready():
	pass

func getEnemyWizard() -> Wizard:
	var enemyWizards := []

	for enemyTeamIndex in Global.game.getEnemyTeamIndices(teamIndex):
		enemyWizards = enemyWizards + Global.game.getWizardsFromTeamIndex(enemyTeamIndex)

	if enemyWizards.empty():
		return null

	# Assume maximum of only one wizard per team.
	return enemyWizards.front()
