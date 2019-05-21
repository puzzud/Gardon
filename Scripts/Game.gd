extends Node2D
class_name Game

var teamTurnIndex = 0

export(Array, Color) var teamColors

var activePiece: Piece

func _ready():
	Global.game = self
	
	initializeBoard()
	
	setTeamTurnIndex(teamTurnIndex)

func initializeBoard():
	$Board.clear()
	
	# Fill board with pieces based on their current location.
	for teamPieces in [$Pieces/Team1, $Pieces/Team2]:
		for piece in teamPieces.get_children():
			#print(teamPieces.name + ":" + piece.name)
			if !$Board.insertPiece(piece):
				printerr("Unable to insert piece into board: " + piece.name)
	
	#print($Board.cellContents)

func setTeamTurnIndex(teamTurnIndex: int):
	self.teamTurnIndex = teamTurnIndex
	
	$Cursor.modulate = getTeamColor(teamTurnIndex)
	
	calculateCellActions()
	$Board.overlayCellActions()

func getTeamColor(teamIndex: int) -> Color:
	var teamColor = teamColors[teamIndex]
	return teamColor

func onBoardCellHover(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	$Cursor.set_global_position($Board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	$Cursor.visible = true
	
	#var cellContent = $Board.getCellContent(cellCoordinates)

func onBoardCellPress(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	var cellPiece = $Board.getCellContent(cellCoordinates)
	if cellPiece == null:
		if activePiece != null:
			# Can the active piece move to this cell?
			if $Board.getCellActionFromCellCoordinates(cellCoordinates) == $Board.CELL_ACTION_ACTIVATE:
				activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
				$Board.removePiece(activePiece)
				$Board.insertPiece(activePiece, cellCoordinates)
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
					return
				else:
					# Can the active piece attack this cell?
					if $Board.getCellActionFromCellCoordinates(cellCoordinates) == $Board.CELL_ACTION_ATTACK:
						activePiece.attack(cellPiece)
						activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
						$Board.removePiece(activePiece)
		else:
			if cellPiece.teamIndex == teamTurnIndex:
				setPieceActivated(cellPiece, true)
				return

func setPieceActivated(piece: Piece, activated: bool):
	piece.setActivated(activated)
	
	if activated:
		activePiece = piece
	else:
		activePiece = null
	
	calculateCellActions()
	$Board.overlayCellActions()

func processPieceAttackingPiece(attackingPiece, targetPiece):
	var cellCoordinates = $Board.getCellCoordinatesFromPiece(targetPiece)
	$Board.removePiece(targetPiece)
	targetPiece.queue_free()
	$Board.insertPiece(attackingPiece, cellCoordinates)

func calculateCellActions():
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
		
		for distance in range(1, piece.movementRange + 1):
			var scaledMovementDirectionCellOffset = movementDirectionCellOffset * distance
			
			var offsetCellCoordinates = $Board.getCellCoordinatesFromCellOffset(cellCoordinates, scaledMovementDirectionCellOffset)
			if offsetCellCoordinates == null:
				break
			
			var offsetCellContents = $Board.getCellContent(offsetCellCoordinates)
			if offsetCellContents == null:
				$Board.cellActions[offsetCellCoordinates.y][offsetCellCoordinates.x] = $Board.CELL_ACTION_ACTIVATE
			else:
				if offsetCellContents.teamIndex == piece.teamIndex:
					break
				else:
					$Board.cellActions[offsetCellCoordinates.y][offsetCellCoordinates.x] = $Board.CELL_ACTION_ATTACK
					break

func endTurn():
	var nextTeamTurnIndex = teamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	$Cursor.visible = false
	
	var winningTeamIndex = getWinningTeamIndex()
	if winningTeamIndex < 0:
		setTeamTurnIndex(nextTeamTurnIndex)
	else:
		endGame(winningTeamIndex)

func endGame(winningTeamIndex):
	$Ui.declareWinner(winningTeamIndex)
	
	$Timers/EndGameTimer.start()

func getWinningTeamIndex():
	return -1

func onOkButtonPressed():
	endTurn()

func onEndGameTimerTimeout():
	get_tree().reload_current_scene()
