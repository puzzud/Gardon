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

var turnActions = []

func _ready():
	Global.game = self
	
	initializeBoard()
	
	setTeamTurnIndex(teamTurnIndex)
	
	$Cursor.visible = false

func _process(delta):
	while !turnActions.empty():
		var turnAction: Action = turnActions.pop_front()
		processCellAction(turnAction.cellCoordinates)

func initializeBoard():
	$Board.initialize()
	
	var initialBoardCellContentInformation8x8 = [
		[{}, {"type": "pawn", "teamIndex": 1}, {}, {"type": "wizard", "teamIndex": 1}, {}, {}, {"type": "pawn", "teamIndex": 1}, {}],
		[{}, {}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {}, {}, {}, {}, {}, {}],
		[{}, {}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {"type": "pawn", "teamIndex": 0}, {}, {}],
		[{}, {"type": "pawn", "teamIndex": 0}, {}, {}, {"type": "wizard", "teamIndex": 0}, {}, {"type": "pawn", "teamIndex": 0}, {}]
	]
	
	#var initialBoardCellContentInformation3x3QuickAiUseAttack = [
	#	[{"type": "wizard", "teamIndex": 1}, {"type": "pawn", "teamIndex": 1}, {"type": "wizard", "teamIndex": 0}],
	#	[{}, {}, {}],
	#	[{}, {}, {}]
	#]
	
	var initialBoardCellContentInformation3x3 = [
		[{"type": "wizard", "teamIndex": 1}, {}, {}],
		[{}, {"type": "pawn", "teamIndex": 1}, {}],
		[{"type": "pawn", "teamIndex": 0}, {"type": "wizard", "teamIndex": 0}, {}]
	]
	
	var initialBoardCellContentInformation = initialBoardCellContentInformation8x8
	if $Board.dimensions.x == 8:
		initialBoardCellContentInformation = initialBoardCellContentInformation8x8
	elif $Board.dimensions.x == 3:
		initialBoardCellContentInformation = initialBoardCellContentInformation3x3
	
	# Fill board with pieces.
	for y in range(0, $Board.dimensions.y):
		var row = initialBoardCellContentInformation[y]
		
		for x in range(0, $Board.dimensions.x):
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
					teamNode = $Pieces/Team0
				elif teamIndex == 1:
					teamNode = $Pieces/Team1
				
				teamNode.add_child(piece)
				
				var cellCoordinates = Vector2(x, y)
				piece.setPosition($Board.getCellPosition(cellCoordinates) + piece.BoardCellOffset)
				if !$Board.insertPiece(piece):
					printerr("Unable to insert piece into board: " + piece.name)

func getBoard() -> Board:
	var board: Board = $Board
	return board

func setTeamTurnIndex(teamTurnIndex: int, simulate: bool = false):
	self.teamTurnIndex = teamTurnIndex
	
	calculateCellActions()
	
	if !simulate:
		$Cursor.setMainColor(getTeamColor(teamTurnIndex))
		$Ui.indicateTeamTurn(teamTurnIndex)
		$Board.overlayCellActions()
		
		faceWizards()
		
		$AudioPlayers/StartTurn1.play()
		
		if Global.playerTypes[teamTurnIndex] == Global.PlayerType.COMPUTER:
			var turn: Turn = decideTurn(teamTurnIndex)
			self.teamTurnIndex = teamTurnIndex
			performTurn(turn)
			
			# TODO: Remove when computer turn is executed.
			#$Board.clearCellActions()
			#activePieceStack.clear()
			#calculateCellActions()
			#$Board.overlayCellActions()

func getTeamName(teamIndex: int) -> String:
	return teamNames[teamIndex]

func getTeamColor(teamIndex: int) -> Color:
	return teamColors[teamIndex]

func getCursor() -> Cursor:
	var cursor: Cursor = $Cursor
	return cursor

func processCellAction(cellCoordinates: Vector2, simulate: bool = false):
	var cellAction = $Board.getCellAction(cellCoordinates)
	
	if cellAction == BoardCell.CellAction.MOVE:
		processCellActionMove(cellCoordinates, simulate)
	elif cellAction == BoardCell.CellAction.DEACTIVATE:
		processCellActionDeactivate(cellCoordinates, simulate)
	elif cellAction == BoardCell.CellAction.USE:
		processCellActionUse(cellCoordinates, simulate)
	elif cellAction == BoardCell.CellAction.ATTACK:
		processCellActionAttack(cellCoordinates, simulate)
	elif cellAction == BoardCell.CellAction.ACTIVATE:
		processCellActionActivate(cellCoordinates, simulate)

func processCellActionMove(cellCoordinates: Vector2, simulate: bool = false):
	var activePiece = getActivePiece()
	
	if !simulate:
		activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
		addProcessingPiece(activePiece)
	else:
		if activePiece.boardCellContent.user != null:
			setPieceActivated(activePiece.boardCellContent.user.piece, false, !simulate, simulate)
	
	$Board.removePiece(activePiece)
	$Board.insertPiece(activePiece, cellCoordinates)
	
	var user = activePiece.boardCellContent.user
	if user != null:
		setPieceActivated(user.piece, false, false, simulate)
	
	$Board.clearCellActions()
	
	if !simulate:
		$Board.overlayCellActions()
		$Cursor.setFlashingColor(false)
	
	return

func processCellActionDeactivate(cellCoordinates: Vector2, simulate: bool = false):
	var activePiece = getActivePiece()
	setPieceActivated(activePiece, false, !simulate, simulate)
	
	return

func processCellActionUse(cellCoordinates: Vector2, simulate: bool = false):
	var activePiece = getActivePiece()
	var cellPiece = $Board.getCellContent(cellCoordinates).piece
	cellPiece.boardCellContent.user = activePiece.boardCellContent
	setPieceActivated(cellPiece, true, !simulate, simulate)
	
	return

func processCellActionAttack(cellCoordinates: Vector2, simulate: bool = false):
	var activePiece = getActivePiece()
	var cellPiece = $Board.getCellContent(cellCoordinates).piece
	
	if !simulate:
		activePiece.attack(cellPiece)
		activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
		addProcessingPiece(activePiece)
	else:
		if activePiece.boardCellContent.user != null:
			setPieceActivated(activePiece.boardCellContent.user.piece, false, !simulate, simulate)
	
	$Board.removePiece(activePiece)
	$Board.insertPiece(activePiece, cellCoordinates)
	
	$Board.clearCellActions()
	
	if !simulate:
		$Board.overlayCellActions()
		$Cursor.setFlashingColor(false)
	
	return

func processCellActionActivate(cellCoordinates: Vector2, simulate: bool = false):
	var cellContent = $Board.getCellContent(cellCoordinates)
	setPieceActivated(cellContent.piece, true, !simulate, simulate)
	
	return

func setPieceActivated(piece: Piece, activated: bool, updateCellActions: bool = true, simulate: bool = false):
	if !simulate:
		piece.setActivated(activated)
	
	if activated:
		setActivePiece(piece)
	else:
		piece.boardCellContent.user = null
		removeActivePiece(piece)
	
	if updateCellActions:
		calculateCellActions()
		
		if !simulate:
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
	if cellCoordinates == null:
		return
	
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

func decideTurn(teamIndex: int) -> Turn:
	#$Board.print()
	return getBestTurn(teamIndex, teamIndex, null)

func getBestTurn(teamIndex: int, positiveTeamIndex: int, turn: Turn, depth: int = 0) -> Turn:
	if turn == null:
		var winningTeamIndex = getWinningTeamIndex()
		if winningTeamIndex > -1:
			turn = Turn.new()
			if winningTeamIndex == positiveTeamIndex:
				turn.score = 10
			else:
				turn.score = -10
			
			return turn
	
	if depth > 1:
		turn = Turn.new()
		turn.score = 0
		return turn
	
	setTeamTurnIndex(teamIndex, true)
	
	var possibleTurns = []
	
	for y in range(0, $Board.cells.size()):
		var row = $Board.cells[y]
		for x in range(0, row.size()):
			var cell: BoardCell = row[x]
			
			if turn == null && getActivePiece() != null:
				turn = Turn.new()
				var action := Action.new()
				action.cellAction = BoardCell.CellAction.ACTIVATE
				action.cellCoordinates = $Board.getCellCoordinatesFromPiece(getActivePiece())
				turn.actions.append(action)
			
			var cellAction = cell.action
			if cellAction == BoardCell.CellAction.ACTIVATE:
				var cellPiece = $Board.getCellContent(Vector2(x, y)).piece
				
				if Global.debug:
					if depth == 0:
						print(str(teamIndex) + "# Found activate: " + str(x) + ":" + str(y) + " \"" + cellPiece.name + "\"")
				
				turn = Turn.new()
				turn.teamIndex = teamIndex
				
				var action := Action.new()
				action.cellAction = cellAction
				action.cellCoordinates = Vector2(x, y)
				turn.actions.append(action)
				
				processCellActionActivate(action.cellCoordinates, true)
				
				if Global.debug:
					if depth == 0:
						$Board.print()
				
				possibleTurns.append(getBestTurn(teamIndex, positiveTeamIndex, turn, depth))
				
				activePieceStack.clear()
				calculateCellActions()
			
			elif cellAction == BoardCell.CellAction.USE && false:
				var cellPiece = $Board.getCellContent(Vector2(x, y)).piece
				
				if Global.debug:
					if depth == 0:
						print(str(teamIndex) + "# Found use: " + str(x) + ":" + str(y) + " \"" + cellPiece.name + "\"")
				
				var action := Action.new()
				action.cellAction = cellAction
				action.cellCoordinates = Vector2(x, y)
				turn.actions.append(action)
				
				var activePiece = getActivePiece()
				var activePieceCellCoordinates = $Board.getCellCoordinatesFromPiece(activePiece)
				
				processCellActionUse(action.cellCoordinates, true)
				
				if Global.debug:
					if depth == 0:
						$Board.print()
				
				possibleTurns.append(getBestTurn(teamIndex, positiveTeamIndex, turn, depth))
				
				cellPiece.boardCellContent.user = null
				activePieceStack.clear()
				processCellActionActivate(activePieceCellCoordinates, true)
				calculateCellActions()
			
			elif cellAction == BoardCell.CellAction.MOVE || cellAction == BoardCell.CellAction.ATTACK:
				var action := Action.new()
				action.cellAction = cellAction
				action.cellCoordinates = Vector2(x, y)
				turn.actions.append(action)
				
				var activePiece = getActivePiece()
				var activePieceCellCoordinates = $Board.getCellCoordinatesFromPiece(activePiece)
				
				if cellAction == BoardCell.CellAction.MOVE:
					
					if Global.debug:
						if depth == 0:
							print(str(teamIndex) + "# Found move: " + str(x) + ":" + str(y))
					
					processCellActionMove(action.cellCoordinates, true)
					processCellActionDeactivate(action.cellCoordinates, true)
					
					if Global.debug:
						if depth == 0:
							$Board.print()
					
					var otherTeamTurnIndex = getNextTeamTurnIndex(teamIndex)
					turn.score = getBestTurn(otherTeamTurnIndex, positiveTeamIndex, null, depth + 1).score
					
					activePieceStack.clear()
					calculateCellActions()
					
					processCellActionActivate(action.cellCoordinates, true)
					processCellActionMove(activePieceCellCoordinates, true)
					
				elif cellAction == BoardCell.CellAction.ATTACK:
					
					if Global.debug:
						if depth == 0:
							print(str(teamIndex) + "# Found attack: " + str(x) + ":" + str(y))
					
					var cellPiece = $Board.getCellContent(action.cellCoordinates).piece
					
					processCellActionAttack(action.cellCoordinates, true)
					processCellActionDeactivate(action.cellCoordinates, true)
					
					if Global.debug:
						if depth == 0:
							$Board.print()
					
					var otherTeamTurnIndex = getNextTeamTurnIndex(teamIndex)
					turn.score = getBestTurn(otherTeamTurnIndex, positiveTeamIndex, null, depth + 1).score
					
					activePieceStack.clear()
					calculateCellActions()
					
					processCellActionActivate(action.cellCoordinates, true)
					processCellActionMove(activePieceCellCoordinates, true)
					
					$Board.insertPiece(cellPiece, action.cellCoordinates)
				
				possibleTurns.append(turn)
				turn = null
				
				setTeamTurnIndex(teamIndex, true)
	
	if possibleTurns.empty():
		turn = Turn.new()
		turn.score = 0
		return turn
	
	var bestTurn = null
	
	if teamIndex == positiveTeamIndex:
		var bestScore = -100
		for possibleTurn in possibleTurns:
			if possibleTurn.score > bestScore:
				bestScore = possibleTurn.score
				bestTurn = possibleTurn
	else:
		var worstScore = 100
		for possibleTurn in possibleTurns:
			if possibleTurn.score < worstScore:
				worstScore = possibleTurn.score
				bestTurn = possibleTurn
	
	var randomizeTurnTies := false
	if randomizeTurnTies:
		if possibleTurns.size() > 1:
			var allSameScores := true
			var previousScore: int = possibleTurns[0].score
			for i in range(1, possibleTurns.size()):
				if possibleTurns[i].score != previousScore:
					allSameScores = false
					break
				else:
					previousScore = possibleTurns[i].score
			
			if allSameScores:
				randomize()
				var i = randi() & range(0, possibleTurns.size() - 1).size()
				bestTurn = possibleTurns[i]
	
	return bestTurn

func performTurn(turn: Turn):
	for action in turn.actions:
		turnActions.append(action)
		#print(str(action.cellCoordinates))
		#print(cellActionNames[action.cellAction])
	
	if turn != null:
		turn.free()

func getNextTeamTurnIndex(currentTeamTurnIndex: int) -> int:
	var nextTeamTurnIndex = currentTeamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	return nextTeamTurnIndex

func endTurn():
	turnActionPerformed = false
	
	var winningTeamIndex = getWinningTeamIndex()
	if winningTeamIndex < 0:
		setTeamTurnIndex(getNextTeamTurnIndex(teamTurnIndex))
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
