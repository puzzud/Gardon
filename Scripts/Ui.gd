extends CanvasLayer

const defaultCaptionTextColor: Color = Color("f4f4f4")

var pauseBoardInteraction := false

var cursorCellCoordinates: Vector2 = Vector2(0, 0)

func _ready():
	$CaptionMessageBox/Text.text = ""

func indicateTeamTurn(teamIndex: int):
	var teamName: String = Global.game.getTeamName(teamIndex)
	var teamColor: Color = Global.game.getTeamColor(teamIndex)
	
	$Title.text = teamName.to_upper() + " TURN"
	$Title["custom_colors/font_color"] = teamColor

func declareWinner(winningTeamIndex: int):
	var teamName: String = Global.game.getTeamName(winningTeamIndex)
	var teamColor: Color = Global.game.getTeamColor(winningTeamIndex)
	
	$Title["custom_colors/font_color"] = teamColor
	$Title.text = teamName.to_upper() + " WINS"
	
	setCaptionText(teamName.to_upper() + " WINS!", teamColor)

func setCaptionText(text: String, color: Color = defaultCaptionTextColor):
	$CaptionMessageBox/Text["custom_colors/font_color"] = color
	$CaptionMessageBox/Text.text = text

func setCursorPositionFromCellCoordinates(cellCoordinates: Vector2):
	var cursor: Cursor = Global.game.getCursor()
	cursor.cellCoordinates = cellCoordinates
	
	var board: Board = Global.game.getBoard()
	cursor.set_global_position(board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	var cellAction = board.getCellAction(cellCoordinates)
	var cellHasAction = (cellAction != BoardCell.CellAction.NONE)
	cursor.setFlashingColor(cellHasAction)
	
	updateCaptionTextFromCellCoordinates(cellCoordinates)

func updateCaptionTextFromCellCoordinates(cellCoordinates: Vector2):
	var cellAction = Global.game.getBoard().getCellAction(cellCoordinates)
	
	var actionName = ""
	var cellActionColor := Color("f4f4f4")
	
	var cellActionNames = Global.game.cellActionNames
	var cellActionColors = Global.game.cellActionColors
	
	if cellActionNames.has(cellAction):
		actionName = cellActionNames[cellAction].to_upper()
	
	if !actionName.empty():
		if cellActionColors.has(cellAction):
			cellActionColor = cellActionColors[cellAction]
		else:
			printerr("No color for cell action: " + str(cellAction))
	
	setCaptionText(actionName, cellActionColor)

func onBoardCellHover(cellCoordinates: Vector2):
	if pauseBoardInteraction:
		return
	
	cursorCellCoordinates = cellCoordinates
	setCursorPositionFromCellCoordinates(cursorCellCoordinates)
	Global.game.getCursor().visible = true

func onBoardCellPress(cellCoordinates: Vector2):
	if pauseBoardInteraction:
		return
	
	cursorCellCoordinates = cellCoordinates
	setCursorPositionFromCellCoordinates(cursorCellCoordinates)
	
	Global.game.processCellAction(cellCoordinates)
