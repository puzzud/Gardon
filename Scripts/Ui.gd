extends CanvasLayer

func _ready():
	$CaptionMessageBox/Text.text = ""

func indicateTeamTurn(teamIndex: int):
	var teamName: String = Global.game.teamNames[teamIndex]
	var teamColor: Color = Global.game.teamColors[teamIndex]
	
	$Title.text = teamName.to_upper() + " TURN"
	$Title["custom_colors/font_color"] = teamColor

func declareWinner(winningTeamIndex: int):
	var teamName: String = Global.game.teamNames[winningTeamIndex]
	
	$CaptionMessageBox/Text.text = teamName.to_upper() + " WINS!"
