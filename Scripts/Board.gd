extends Node2D
class_name Board

var boardCellClass = preload("res://Scripts/BoardCell.gd")

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

var cellActions = [
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1]
]

var tileNameCellActionOverlayTable = {
	"": boardCellClass.CellAction.NONE,
	"GroundLightBlue": boardCellClass.CellAction.ACTIVATE,
	"GroundRed": boardCellClass.CellAction.ATTACK,
	"GroundGreen": boardCellClass.CellAction.USE
}

var cellActionOverlayTileIndexTable = {}

var cellActionNames = {
	boardCellClass.CellAction.NONE: "",
	boardCellClass.CellAction.ACTIVATE: "Activate",
	boardCellClass.CellAction.ATTACK: "Attack",
	boardCellClass.CellAction.USE: "Use"
}

var cellActionColors = {
	boardCellClass.CellAction.ACTIVATE: Color("73eff7"),
	boardCellClass.CellAction.ATTACK: Color("b13e53"),
	boardCellClass.CellAction.USE: Color("38b764")
}

func _ready():
	buildCellActionOverlayTileIndexTable()
	initializeCellActions()
	
	overlayCellActions()

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

func buildCellActionOverlayTileIndexTable():
	var cellsOverlayTileSet = $CellsOverlay.tile_set
	
	for key in tileNameCellActionOverlayTable.keys():
		if key.empty():
			continue
		
		var tileIndex = cellsOverlayTileSet.find_tile_by_name(key)
		if tileIndex != null:
			cellActionOverlayTileIndexTable[tileNameCellActionOverlayTable[key]] = tileIndex

func initializeCellActions():
	clearCellActions()

func clear():
	for row in cellContents:
		for x in range(0, row.size()):
			row[x] = null

func getCellContent(cellCoordinates: Vector2):
	# TODO: Do bound checking.
	
	return cellContents[cellCoordinates.y][cellCoordinates.x]

func clearCell(cellCoordinates):
	cellContents[cellCoordinates.y][cellCoordinates.x] = null

func insertPiece(piece: Piece, cellCoordinates = null):
	if cellCoordinates == null:
		cellCoordinates = getCellCoordinatesFromPiecePosition(piece)
	
	if cellCoordinates == null:
		return false
	
	cellContents[cellCoordinates.y][cellCoordinates.x] = piece
	
	return true

func removePiece(piece: Piece):
	var cellCoordinates = getCellCoordinatesFromPiece(piece)
	if cellCoordinates != null:
		clearCell(cellCoordinates)

func getCellPosition(cellCoordinates: Vector2):
	return global_position + TileMapOffset + (cellCoordinates * CellDimensions) - Vector2(1.0, 1.0)

func getCellCoordinatesFromPosition(position: Vector2):
	var cellCoordinates = Vector2()
	
	var cellFirstPosition = global_position + TileMapOffset
	
	cellCoordinates.x = int((position.x - cellFirstPosition.x) / CellDimensions.x)
	cellCoordinates.y = int((position.y - cellFirstPosition.y) / CellDimensions.y)
	
	if areCellCoordinatesOutOfBounds(cellCoordinates):
		return null
	
	return cellCoordinates

func getCellCoordinatesFromPiecePosition(piece: Piece):
	return getCellCoordinatesFromPosition(piece.global_position)

func getCellCoordinatesFromPiece(piece: Piece):
	for y in range(0, cellContents.size()):
		var row = cellContents[y]
		for x in range(0, row.size()):
			if row[x] == piece:
				return Vector2(x, y)
	
	return null

func getCellCoordinatesFromCellOffset(cellCoordinates: Vector2, cellOffset: Vector2):
	var offsetCellCoordinates = cellCoordinates + cellOffset
	
	if areCellCoordinatesOutOfBounds(offsetCellCoordinates):
		return null
	
	return offsetCellCoordinates
	
func areCellCoordinatesOutOfBounds(cellCoordinates: Vector2):
	# TODO: Make upper bounds actually use board dimensions.
	if cellCoordinates.x < 0 || cellCoordinates.x >= 8:
		return true
	
	if cellCoordinates.y < 0 || cellCoordinates.y >= 8:
		return true
	
	return false

func getCellOffsetFromDirection(direction: int) -> Vector2:
	var cellOffset = Vector2()
	
	if direction & Global.DIRECTION_FLAG_LEFT:
		cellOffset.x = cellOffset.x - 1
		
	if direction & Global.DIRECTION_FLAG_RIGHT:
		cellOffset.x = cellOffset.x + 1
	
	if direction & Global.DIRECTION_FLAG_UP:
		cellOffset.y = cellOffset.y - 1
	
	if direction & Global.DIRECTION_FLAG_DOWN:
		cellOffset.y = cellOffset.y + 1
	
	return cellOffset

func getCellActionFromCellCoordinates(cellCoordinates: Vector2) -> int:
	return cellActions[cellCoordinates.y][cellCoordinates.x]

func clearCellActions():
	for y in range(0, cellActions.size()):
		var row = cellActions[y]
		for x in range(0, row.size()):
			row[x] = boardCellClass.CellAction.NONE

func overlayCellActions():
	for y in range(0, cellActions.size()):
		var row = cellActions[y]
		for x in range(0, row.size()):
			var tileIndex = -1
			var cellAction = row[x]
			if cellAction != boardCellClass.CellAction.NONE:
				if !cellActionOverlayTileIndexTable.has(cellAction):
					printerr("No tile index for cell action: " + str(cellAction))
				else:
					tileIndex = cellActionOverlayTileIndexTable[cellAction]
			$CellsOverlay.set_cell(x, y, tileIndex)
