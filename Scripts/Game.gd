extends Node2D
class_name Game

var teamTurnIndex = 0

# warning-ignore:unused_class_variable
export(Array, String) var teamNames
export(Array, Color) var teamColors

var cursorCellCoordinates: Vector2 = Vector2(0, 0)

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
	$Board.clear()
	
	# Fill board with pieces based on their current location.
	for teamPieces in [getTeamPieces(0), getTeamPieces(1)]:
		for teamPiece in teamPieces:
			if !$Board.insertPiece(teamPiece):
				printerr("Unable to insert piece into board: " + teamPiece.name)
	
	#print($Board.cellContents)

func setTeamTurnIndex(teamTurnIndex: int):
	self.teamTurnIndex = teamTurnIndex
	
	$Cursor.setMainColor(getTeamColor(teamTurnIndex))
	
	$Ui.indicateTeamTurn(teamTurnIndex)
	
	calculateCellActions()
	$Board.overlayCellActions()
	
	$AudioPlayers/StartTurn1.play()

func getTeamColor(teamIndex: int) -> Color:
	var teamColor = teamColors[teamIndex]
	return teamColor

func setCursorPositionFromCellCoordinates(cellCoordinates: Vector2):
	$Cursor.set_global_position($Board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	$Cursor.setFlashingColor($Board.getCellActionFromCellCoordinates(cellCoordinates) != $Board.CELL_ACTION_NONE)

func onBoardCellHover(cellCoordinates: Vector2):
	cursorCellCoordinates = cellCoordinates
	
	if isGameOver:
		return
	
	var activePiece = getActivePiece()
	if activePiece != null && activePiece.moving:
		return
	
	setCursorPositionFromCellCoordinates(cursorCellCoordinates)
	$Cursor.visible = true
	
	#var cellContent = $Board.getCellContent(cellCoordinates)

func onBoardCellPress(cellCoordinates: Vector2):
	cursorCellCoordinates = cellCoordinates
	
	if isGameOver:
		return
	
	var activePiece = getActivePiece()
	if activePiece != null && activePiece.moving:
		return
	
	setCursorPositionFromCellCoordinates(cursorCellCoordinates)
	
	var cellPiece = $Board.getCellContent(cellCoordinates)
	if cellPiece == null:
		if activePiece != null:
			# Can the active piece move to this cell?
			if $Board.getCellActionFromCellCoordinates(cellCoordinates) == $Board.CELL_ACTION_ACTIVATE:
				activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
				$Board.removePiece(activePiece)
				$Board.insertPiece(activePiece, cellCoordinates)
				
				addProcessingPiece(activePiece)
				
				$Board.clearCellActions()
				$Board.overlayCellActions()
				$Cursor.setFlashingColor(false)
			return
		else:
			return
	else:
		if activePiece != null:
			if activePiece == cellPiece:
				setPieceActivated(activePiece, false)
				return
			else:
				if cellPiece.teamIndex == activePiece.teamIndex:
					if $Board.getCellActionFromCellCoordinates(cellCoordinates) == $Board.CELL_ACTION_USE:
						cellPiece.user = activePiece
						setPieceActivated(cellPiece, true)
						return
				else:
					# Can the active piece attack this cell?
					if $Board.getCellActionFromCellCoordinates(cellCoordinates) == $Board.CELL_ACTION_ATTACK:
						activePiece.attack(cellPiece)
						activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
						$Board.removePiece(activePiece)
						
						addProcessingPiece(activePiece)
						
						$Board.clearCellActions()
						$Board.cellActions[cellCoordinates.y][cellCoordinates.x] = $Board.CELL_ACTION_ATTACK
						$Board.overlayCellActions()
						$Cursor.setFlashingColor(false)
		else:
			if cellPiece.teamIndex == teamTurnIndex:
				setPieceActivated(cellPiece, true)
				return

func setPieceActivated(piece: Piece, activated: bool, updateCellActions: bool = true):
	piece.setActivated(activated)
	
	if activated:
		setActivePiece(piece)
	else:
		removeActivePiece(piece)
	
	if updateCellActions:
		calculateCellActions()
		$Board.overlayCellActions()

func processPieceAttackingPiece(attackingPiece, targetPiece):
	var cellCoordinates = $Board.getCellCoordinatesFromPiece(targetPiece)
	$Board.removePiece(targetPiece)
	targetPiece.receiveDamage(5.0, attackingPiece)
	
	$Board.insertPiece(attackingPiece, cellCoordinates)
	
	$Board.clearCellActions()
	$Board.overlayCellActions()

func calculateCellActions():
	var activePiece = getActivePiece()
	if activePiece != null:
		calculateCellActionsForPiece(activePiece)
	else:
		calculateCellActionsForTeam(teamTurnIndex)
	
func calculateCellActionsForTeam(teamIndex: int):
	for y in range(0, $Board.cellContents.size()):
		var row = $Board.cellContents[y]
		for x in range(0, row.size()):
			var piece: Piece = row[x]
			if piece == null:
				$Board.cellActions[y][x] = $Board.CELL_ACTION_NONE
			else:
				if piece.teamIndex == teamIndex:
					$Board.cellActions[y][x] = $Board.CELL_ACTION_ACTIVATE
				else:
					$Board.cellActions[y][x] = $Board.CELL_ACTION_NONE

func calculateCellActionsForPiece(piece: Piece):
	$Board.clearCellActions()
	
	var cellCoordinates = $Board.getCellCoordinatesFromPiece(piece)
	$Board.cellActions[cellCoordinates.y][cellCoordinates.x] = $Board.CELL_ACTION_ACTIVATE
	
	var pieceMovementDirections = piece.getMovementDirections()
	for movementDirection in pieceMovementDirections:
		var movementDirectionCellOffset = $Board.getCellOffsetFromDirection(movementDirection)
		
		var movementRange = piece.movementRange
		if piece.user != null:
			movementRange = 7 # TODO: Determine this in a better way.
		
		for distance in range(1, movementRange + 1):
			var scaledMovementDirectionCellOffset = movementDirectionCellOffset * distance
			
			var offsetCellCoordinates = $Board.getCellCoordinatesFromCellOffset(cellCoordinates, scaledMovementDirectionCellOffset)
			if offsetCellCoordinates == null:
				break
			
			var offsetCellContents = $Board.getCellContent(offsetCellCoordinates)
			if offsetCellContents == null:
				$Board.cellActions[offsetCellCoordinates.y][offsetCellCoordinates.x] = $Board.CELL_ACTION_ACTIVATE
			else:
				if offsetCellContents.teamIndex == piece.teamIndex:
					if piece.canUsePieces && distance == 1:
						$Board.cellActions[offsetCellCoordinates.y][offsetCellCoordinates.x] = $Board.CELL_ACTION_USE
					break
				else:
					$Board.cellActions[offsetCellCoordinates.y][offsetCellCoordinates.x] = $Board.CELL_ACTION_ATTACK
					break

func endTurn():
	turnActionPerformed = false
	
	var nextTeamTurnIndex = teamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	#$Cursor.visible = false
	setCursorPositionFromCellCoordinates(cursorCellCoordinates)
	
	var winningTeamIndex = getWinningTeamIndex()
	if winningTeamIndex < 0:
		setTeamTurnIndex(nextTeamTurnIndex)
	else:
		endGame(winningTeamIndex)

func endGame(winningTeamIndex):
	isGameOver = true
	
	$Ui.declareWinner(winningTeamIndex)
	
	$Timers/EndGameTimer.start()
	
	$AudioPlayers/EndGame1.play()

func getWinningTeamIndex():
	var team0Pieces = getTeamPieces(0)
	var team1Pieces = getTeamPieces(1)
	
	var numberOfAliveTeam0Pieces = getNumberOfAlivePieces(team0Pieces)
	var numberOfAliveTeam1Pieces = getNumberOfAlivePieces(team1Pieces)
	
	if numberOfAliveTeam0Pieces == 0:
		return 1
	elif numberOfAliveTeam1Pieces == 0:
		return 0
	
	return -1

func getTeamPieces(teamIndex: int) -> Array:
	var teamNumber = teamIndex + 1
	
	var piecesNode = $Pieces
	var teamPiecesNode = piecesNode.get_node("Team" + str(teamNumber))
	if teamPiecesNode == null:
		return []
	
	return teamPiecesNode.get_children()

func getNumberOfAlivePieces(pieces: Array):
	var numberOfAlivePieces := 0
	
	for piece in pieces:
		if piece.alive:
			numberOfAlivePieces = numberOfAlivePieces + 1
	
	return numberOfAlivePieces

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

func removeProcessingPiece(piece: Piece):
	var index = piecesThatAreProcessing.find(piece)
	if index < 0:
		return
	
	piecesThatAreProcessing.remove(index)
	
	if piecesThatAreProcessing.empty():
		if activePieceStack.empty():
			endTurn()

func onOkButtonPressed():
	endTurn()

func onEndGameTimerTimeout():
	get_tree().reload_current_scene()
