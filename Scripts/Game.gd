extends Node2D
class_name Game

var teamTurnIndex = 0

export(Array, Color) var teamColors

var activePiece: Piece = null

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

func getTeamColor(teamIndex: int) -> Color:
	var teamColor = teamColors[teamIndex]
	return teamColor

func onBoardCellHover(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	$Cursor.set_global_position($Board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	#var cellContent = $Board.getCellContent(cellCoordinates)

func onBoardCellPress(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	var cellPiece = $Board.getCellContent(cellCoordinates)
	if cellPiece == null:
		if activePiece != null:
			# TODO: Can active piece move to this cell?
			activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
			$Board.removePiece(activePiece)
			$Board.insertPiece(activePiece, cellCoordinates)
			return
		else:
			return
	else:
		if activePiece != null:
			if activePiece == cellPiece:
				activePiece.setActivated(false)
				activePiece = null
				return
			else:
				if cellPiece.teamIndex == activePiece.teamIndex:
					return
				else:
					# TODO: Can active piece attack this cell?
					activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
					$Board.removePiece(activePiece)
					$Board.removePiece(cellPiece)
					cellPiece.queue_free()
					$Board.insertPiece(activePiece, cellCoordinates)
		else:
			if cellPiece.teamIndex == teamTurnIndex:
				cellPiece.setActivated(true)
				activePiece = cellPiece
				return

func onOkButtonPressed():
	var nextTeamTurnIndex = teamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	setTeamTurnIndex(nextTeamTurnIndex)
