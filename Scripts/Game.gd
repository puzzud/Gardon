extends Node2D
class_name Game

var teamTurnIndex = 0

export(Array, Color) var teamColors

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
	$Cursor.set_global_position($Board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	#var cellContent = $Board.getCellContent(cellCoordinates)
