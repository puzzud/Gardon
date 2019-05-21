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

enum {
	CELL_ACTION_NONE = -1,
	CELL_ACTION_ACTIVATE,
	CELL_ACTION_ATTACK
}

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
	"": CELL_ACTION_NONE,
	"GroundLightBlue": CELL_ACTION_ACTIVATE,
	"GroundRed": CELL_ACTION_ATTACK
}

var cellActionOverlayTileIndexTable = {}

func _ready():
	buildCellActionOverlayTileIndexTable()
	initializeCellActions()
	
	refreshCellOverlays()

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
	if cellCoordinates.x < 0 || cellCoordinates.x >= 8:
		return null
	
	cellCoordinates.y = int((position.y - cellFirstPosition.y) / CellDimensions.y)
	if cellCoordinates.y < 0 || cellCoordinates.y >= 8:
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

func clearCellActions():
	for y in range(0, cellActions.size()):
		var row = cellActions[y]
		for x in range(0, row.size()):
			row[x] = -1

func refreshCellOverlays():
	for y in range(0, cellActions.size()):
		var row = cellActions[y]
		for x in range(0, row.size()):
			var tileIndex = -1
			var cellAction = row[x]
			if cellAction > -1:
				tileIndex = cellActionOverlayTileIndexTable[cellAction]
			$CellsOverlay.set_cell(x, y, tileIndex)

func overlayActivatablePieces(teamIndex):
	for y in range(0, cellContents.size()):
		var row = cellContents[y]
		for x in range(0, row.size()):
			var piece: Piece = row[x]
			if piece == null:
				cellActions[y][x] = -1
			else:
				if piece.teamIndex == teamIndex:
					cellActions[y][x] = CELL_ACTION_ACTIVATE
				else:
					cellActions[y][x] = -1
	
	refreshCellOverlays()
