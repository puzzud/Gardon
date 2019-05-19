extends Node2D
class_name Board

signal cellHover(cellCoordinates)
signal cellPress(cellCoordinates)

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

func _input(event):
	if event is InputEventMouseMotion:
		var cellCoordinates = getCellCoordinatesFromPosition(event.global_position)
		if cellCoordinates != null:
			emit_signal("cellHover", cellCoordinates)
	elif event is InputEventMouseButton:
		var cellCoordinates = getCellCoordinatesFromPosition(event.global_position)
		if cellCoordinates != null:
			if event.pressed:
				emit_signal("cellPress", cellCoordinates)

func clear():
	for row in cellContents:
		for x in range(0, row.size()):
			row[x] = null

func getCellContent(cellCoordinates: Vector2):
	# TODO: Do bound checking.
	
	return cellContents[cellCoordinates.y][cellCoordinates.x]

func insertPiece(piece: Piece):
	var cellCoordinates = getCellCoordinatesFromPiece(piece)
	if cellCoordinates == null:
		return false
	
	cellContents[cellCoordinates.y][cellCoordinates.x] = piece
	
	return true

func getCellPosition(cellCoordinates: Vector2):
	return global_position + TileMapOffset + (cellCoordinates * CellDimensions) - Vector2(1.0, 1.0)

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
