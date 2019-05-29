extends Node2D
class_name Game

const pawnScenePrefab = preload("res://Scenes/Tomato.tscn")
const wizardScenePrefab = preload("res://Scenes/Farmer.tscn")

const cellActionNames = {
	BoardCell.CellAction.NONE: "",
	BoardCell.CellAction.ACTIVATE: "Activate",
	BoardCell.CellAction.DEACTIVATE: "Deactivate",
	BoardCell.CellAction.MOVE: "Move",
	BoardCell.CellAction.ATTACK: "Attack",
	BoardCell.CellAction.USE: "Use"
}

const cellActionColors = {
	BoardCell.CellAction.ACTIVATE: Color("73eff7"),
	BoardCell.CellAction.DEACTIVATE: Color("f4f4f4"),
	BoardCell.CellAction.MOVE: Color("73eff7"),
	BoardCell.CellAction.ATTACK: Color("b13e53"),
	BoardCell.CellAction.USE: Color("38b764")
}

var teamTurnIndex = 0

export(Array, String) var teamNames
export(Array, Color) var teamColors

var activePieceStack: Array = []

var turnActionPerformed: bool = false

var isGameOver: bool = false

var piecesThatAreProcessing = []

func _ready():
	Global.game = self
	
	initializeBoard()
	
	setTeamTurnIndex(teamTurnIndex)
	
	$Cursor.visible = false

func initializeBoard():
	$Board.initialize()
	
	var initialBoardCellContentInformation = [
		[{}, {"type": "pawn", "teamIndex": 1}, {}, {"type": "wizard", "teamIndex": 1}, {}, {}, {"type": "pawn", "teamIndex": 1}, {}],
		[{}, {}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {}, {}],
		[{}, {"type": "pawn", "teamIndex": 0}, {}, {}, {"type": "wizard", "teamIndex": 0}, {}, {"type": "pawn", "teamIndex": 0}, {}]
	]
	
	# Fill board with pieces.
	for y in range(0, initialBoardCellContentInformation.size()):
		var row = initialBoardCellContentInformation[y]
		
		for x in range(0, row.size()):
			var cellContentInformation = row[x]
			
			if !cellContentInformation.empty():
				var type = cellContentInformation["type"]
				var teamIndex = cellContentInformation["teamIndex"]
				
				var boardCellContent = null
				var piece = null
				
				if type == "pawn":
					boardCellContent = Pawn.new()
					piece = pawnScenePrefab.instance()
				elif type == "wizard":
					boardCellContent = Wizard.new()
					piece = wizardScenePrefab.instance()
				
				boardCellContent.initialize()
				
				boardCellContent.teamIndex = teamIndex
				
				boardCellContent.piece = piece
				piece.boardCellContent = boardCellContent
				
				var teamNode = null
				if teamIndex == 0:
					teamNode = $Pieces/Team1
				elif teamIndex == 1:
					teamNode = $Pieces/Team2
				
				teamNode.add_child(piece)
				
				var cellCoordinates = Vector2(x, y)
				piece.setPosition($Board.getCellPosition(cellCoordinates) + piece.BoardCellOffset)
				if !$Board.insertPiece(piece):
					printerr("Unable to insert piece into board: " + piece.name)

func getBoard() -> Board:
	var board: Board = $Board
	return board

func setTeamTurnIndex(teamTurnIndex: int):
	self.teamTurnIndex = teamTurnIndex
	
	$Cursor.setMainColor(getTeamColor(teamTurnIndex))
	
	$Ui.indicateTeamTurn(teamTurnIndex)
	
	calculateCellActions()
	$Board.overlayCellActions()
	
	faceWizards()
	
	$AudioPlayers/StartTurn1.play()

func getTeamName(teamIndex: int) -> String:
	return teamNames[teamIndex]

func getTeamColor(teamIndex: int) -> Color:
	return teamColors[teamIndex]

func getCursor() -> Cursor:
	var cursor: Cursor = $Cursor
	return cursor

func processCellAction(cellCoordinates: Vector2):
	var cellAction = $Board.getCellAction(cellCoordinates)
	
	if cellAction == BoardCell.CellAction.MOVE:
		var activePiece = getActivePiece()
		activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
		$Board.removePiece(activePiece)
		$Board.insertPiece(activePiece, cellCoordinates)
		
		var user = activePiece.boardCellContent.user
		if user != null:
			setPieceActivated(user.piece, false, false)
		
		addProcessingPiece(activePiece)
		
		$Board.clearCellActions()
		$Board.overlayCellActions()
		$Cursor.setFlashingColor(false)
		
		return
	
	if cellAction == BoardCell.CellAction.DEACTIVATE:
		var activePiece = getActivePiece()
		setPieceActivated(activePiece, false)
		
		return
	
	if cellAction == BoardCell.CellAction.USE:
		var activePiece = getActivePiece()
		var cellPiece = $Board.getCellContent(cellCoordinates).piece
		cellPiece.boardCellContent.user = activePiece.boardCellContent
		setPieceActivated(cellPiece, true)
		
		return
	
	if cellAction == BoardCell.CellAction.ATTACK:
		var activePiece = getActivePiece()
		var cellPiece = $Board.getCellContent(cellCoordinates).piece
		activePiece.attack(cellPiece)
		activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
		$Board.removePiece(activePiece)
		$Board.insertPiece(activePiece, cellCoordinates)
		
		addProcessingPiece(activePiece)
		
		$Board.clearCellActions()
		$Board.overlayCellActions()
		$Cursor.setFlashingColor(false)
		
		return
	
	if cellAction == BoardCell.CellAction.ACTIVATE:
		var cellContent = $Board.getCellContent(cellCoordinates)
		setPieceActivated(cellContent.piece, true)
		
		return

func setPieceActivated(piece: Piece, activated: bool, updateCellActions: bool = true):
	piece.setActivated(activated)
	
	if activated:
		setActivePiece(piece)
	else:
		piece.boardCellContent.user = null
		removeActivePiece(piece)
	
	if updateCellActions:
		calculateCellActions()
		$Board.overlayCellActions()
		
		$Ui.updateCaptionTextFromCellCoordinates($Cursor.cellCoordinates)

func processPieceAttackingPiece(attackingPiece, targetPiece):
	targetPiece.receiveDamage(5.0, attackingPiece)

func calculateCellActions():
	var activePiece = getActivePiece()
	if activePiece != null:
		calculateCellActionsForPiece(activePiece)
	else:
		calculateCellActionsForTeam(teamTurnIndex)
	
func calculateCellActionsForTeam(teamIndex: int):
	for y in range(0, $Board.cells.size()):
		var row = $Board.cells[y]
		for x in range(0, row.size()):
			var piece: Piece = row[x].content
			if piece == null:
				row[x].action = BoardCell.CellAction.NONE
			else:
				if piece.teamIndex == teamIndex:
					row[x].action = BoardCell.CellAction.ACTIVATE
				else:
					row[x].action = BoardCell.CellAction.NONE

func calculateCellActionsForPiece(piece: Piece):
	$Board.clearCellActions()
	
	var cellCoordinates = $Board.getCellCoordinatesFromPiece(piece)
	$Board.setCellAction(cellCoordinates, BoardCell.CellAction.DEACTIVATE)
	
	var boardCellContent = piece.boardCellContent
	
	var pieceMovementDirections = boardCellContent.getMovementDirections()
	for movementDirection in pieceMovementDirections:
		var movementDirectionCellOffset = $Board.getCellOffsetFromDirection(movementDirection)
		
		var movementRange = boardCellContent.movementRange
		if boardCellContent.user != null:
			movementRange = 7 # TODO: Determine this in a better way.
		
		for distance in range(1, movementRange + 1):
			var scaledMovementDirectionCellOffset = movementDirectionCellOffset * distance
			
			var offsetCellCoordinates = $Board.getCellCoordinatesFromCellOffset(cellCoordinates, scaledMovementDirectionCellOffset)
			if offsetCellCoordinates == null:
				break
			
			var offsetCellContents = $Board.getCellContent(offsetCellCoordinates)
			if offsetCellContents == null:
				$Board.setCellAction(offsetCellCoordinates, BoardCell.CellAction.MOVE)
			else:
				if offsetCellContents.teamIndex == boardCellContent.teamIndex:
					if boardCellContent.canUsePieces && distance == 1:
						$Board.setCellAction(offsetCellCoordinates, BoardCell.CellAction.USE)
					break
				else:
					if boardCellContent.canAttack:
						$Board.setCellAction(offsetCellCoordinates, BoardCell.CellAction.ATTACK)
					elif boardCellContent.user != null && boardCellContent.user.canAttack:
						$Board.setCellAction(offsetCellCoordinates, BoardCell.CellAction.ATTACK)
					break

func endTurn():
	turnActionPerformed = false
	
	var nextTeamTurnIndex = teamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	var winningTeamIndex = getWinningTeamIndex()
	if winningTeamIndex < 0:
		setTeamTurnIndex(nextTeamTurnIndex)
	else:
		endGame(winningTeamIndex)

func endGame(winningTeamIndex):
	isGameOver = true
	
	$Ui.declareWinner(winningTeamIndex)
	$Ui.pauseBoardInteraction = true
	
	$Timers/EndGameTimer.start()
	
	$AudioPlayers/EndGame1.play()

func getEnemyTeamIndices(teamIndex: int) -> Array:
	var teamIndices := []
	
	if teamIndex == 0:
		teamIndices.append(1)
	elif teamIndex == 1:
		teamIndices.append(0)
	
	return teamIndices

func getWinningTeamIndex():
	var team0BoardCellContents = getTeamBoardCellContents(0)
	var team1BoardCellContents = getTeamBoardCellContents(1)
	
	if team0BoardCellContents.size() == 0:
		return 1
	elif team1BoardCellContents.size() == 0:
		return 0
	
	if getWizardsFromBoardCellContents(team0BoardCellContents).empty():
		return 1
	elif getWizardsFromBoardCellContents(team1BoardCellContents).empty():
		return 0
	
	return -1

func getTeamBoardCellContents(teamIndex: int, board = null) -> Array:
	if board == null:
		board = $Board
	
	var teamBoardCellContents = []
	
	for boardCellContent in board.getAllCellContents():
		if boardCellContent.teamIndex == teamIndex:
			teamBoardCellContents.append(boardCellContent)
	
	return teamBoardCellContents

func getWizards() -> Array:
	var wizards := []
	
	for teamIndex in range(0, 1 + 1):
		var teamWizards = getWizardsFromTeamIndex(teamIndex)
		wizards = wizards + teamWizards
	
	return wizards

func getWizardsFromTeamIndex(teamIndex: int) -> Array:
	var teamBoardCellContents = getTeamBoardCellContents(teamIndex)
	var teamWizards = getWizardsFromBoardCellContents(teamBoardCellContents)
	return teamWizards

func getWizardsFromBoardCellContents(boardCellContents: Array) -> Array:
	var wizards := []
	
	for boardCellContent in boardCellContents:
		if boardCellContent is Wizard:
			wizards.append(boardCellContent)
	
	return wizards

func getActivePiece() -> Piece:
	if activePieceStack.empty():
		return null
	
	return activePieceStack.front()

func setActivePiece(piece: Piece):
	if piece == null:
		printerr("Attempted to set null as an active piece.")
	else:
		activePieceStack.push_front(piece)

func removeActivePiece(piece = null):
	if piece == null:
		activePieceStack.pop_front()
	else:
		var index = activePieceStack.find(piece)
		if index > -1:
			activePieceStack.remove(index)

func addProcessingPiece(piece: Piece):
	piecesThatAreProcessing.append(piece)
	
	$Ui.pauseBoardInteraction = true

func removeProcessingPiece(piece: Piece):
	var index = piecesThatAreProcessing.find(piece)
	if index < 0:
		return
	
	piecesThatAreProcessing.remove(index)
	
	if piecesThatAreProcessing.empty():
		$Ui.pauseBoardInteraction = false
		
		if activePieceStack.empty():
			endTurn()

func faceWizards():
	for wizard in getWizards():
		var wizardPiece: WizardPiece = wizard.piece
		wizardPiece.faceEnemyWizard()

func onEndGameTimerTimeout():
	#get_tree().reload_current_scene()
	
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
