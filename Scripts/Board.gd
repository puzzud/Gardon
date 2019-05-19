extends Node2D
class_name Board

const CellDimensions := Vector2(16.0, 16.0)

const TileMapOffset := Vector2(8.0, 8.0)

var cellContents = [
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null]
]

func _ready():
	pass

func clear():
	for row in cellContents:
		for x in range(0, row.size()):
			row[x] = null

func insertPiece(piece: Piece):
	var boardCellCoordinates = getCellCoordinatesFromPiece(piece)
	if boardCellCoordinates == null:
		return false
	
	cellContents[boardCellCoordinates.y][boardCellCoordinates.x] = piece
	
	return true

func getCellCoordinatesFromPosition(position: Vector2):
	var cellCoordinates = Vector2()
	
	var cellFirstPosition = global_position + TileMapOffset
	
	cellCoordinates.x = int((position.x - cellFirstPosition.x) / CellDimensions.x)
	if cellCoordinates.x < 0 || cellCoordinates.x >= 8:
		return null
	
	cellCoordinates.y = int((position.y - cellFirstPosition.y) / CellDimensions.y)
	if cellCoordinates.y < 0 || cellCoordinates.y >= 8:
		return null
	
	return cellCoordinates

func getCellCoordinatesFromPiece(piece: Piece) -> Vector2:
	return getCellCoordinatesFromPosition(piece.global_position)
