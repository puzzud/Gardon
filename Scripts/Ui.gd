extends CanvasLayer

const defaultCaptionTextColor: Color = Color("f4f4f4")

func _ready():
	$CaptionMessageBox/Text.text = ""

func indicateTeamTurn(teamIndex: int):
	var teamName: String = Global.game.teamNames[teamIndex]
	var teamColor: Color = Global.game.teamColors[teamIndex]
	
	$Title.text = teamName.to_upper() + " TURN"
	$Title["custom_colors/font_color"] = teamColor

func declareWinner(winningTeamIndex: int):
	var teamName: String = Global.game.teamNames[winningTeamIndex]
	var teamColor: Color = Global.game.teamColors[winningTeamIndex]
	
	$Title["custom_colors/font_color"] = teamColor
	$Title.text = teamName.to_upper() + " WINS"
	
	setCaptionText(teamName.to_upper() + " WINS!", teamColor)

func setCaptionText(text: String, color: Color = defaultCaptionTextColor):
	$CaptionMessageBox/Text["custom_colors/font_color"] = color
	$CaptionMessageBox/Text.text = text
