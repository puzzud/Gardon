extends Node2D
class_name Board

signal cellHover(cellCoordinates)
signal cellPress(cellCoordinates)

const CellDimensions := Vector2(16.0, 16.0)

const TileMapOffset := Vector2(8.0, 8.0)

var cells = []

var tileNameCellActionOverlayTable = {
	"": BoardCell.CellAction.NONE,
	"GroundLightBlue": BoardCell.CellAction.ACTIVATE,
	"GroundRed": BoardCell.CellAction.ATTACK,
	"GroundGreen": BoardCell.CellAction.USE
}

var cellActionOverlayTileIndexTable = {}

# warning-ignore:unused_class_variable
var cellActionNames = {
	BoardCell.CellAction.NONE: "",
	BoardCell.CellAction.ACTIVATE: "Activate",
	BoardCell.CellAction.ATTACK: "Attack",
	BoardCell.CellAction.USE: "Use"
}

# warning-ignore:unused_class_variable
var cellActionColors = {
	BoardCell.CellAction.ACTIVATE: Color("73eff7"),
	BoardCell.CellAction.ATTACK: Color("b13e53"),
	BoardCell.CellAction.USE: Color("38b764")
}

func _ready():
	buildCellActionOverlayTileIndexTable()
	
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

func initialize():
	cells = []
	
# warning-ignore:unused_variable
	for y in range(0, 8):
		var row = []
		
# warning-ignore:unused_variable
		for x in range(0, 8):
			var newBoardCell = BoardCell.new()
			
			row.append(newBoardCell)
		
		cells.append(row)
	
	clear()

func buildCellActionOverlayTileIndexTable():
	var cellsOverlayTileSet = $CellsOverlay.tile_set
	
	for key in tileNameCellActionOverlayTable.keys():
		if key.empty():
			continue
		
		var tileIndex = cellsOverlayTileSet.find_tile_by_name(key)
		if tileIndex != null:
			cellActionOverlayTileIndexTable[tileNameCellActionOverlayTable[key]] = tileIndex

func clear():
	for row in cells:
		for x in range(0, row.size()):
			var cell: BoardCell = row[x]
			cell.clear()

func getCellContent(cellCoordinates: Vector2):
	# TODO: Do bound checking.
	
	return cells[cellCoordinates.y][cellCoordinates.x].content

func clearCell(cellCoordinates):
	var cell: BoardCell = cells[cellCoordinates.y][cellCoordinates.x]
	cell.clear()

func insertPiece(piece: Piece, cellCoordinates = null):
	if cellCoordinates == null:
		cellCoordinates = getCellCoordinatesFromPiecePosition(piece)
	
	if cellCoordinates == null:
		return false
	
	cells[cellCoordinates.y][cellCoordinates.x].content = piece
	
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
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			if row[x].content == piece:
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

func getCellAction(cellCoordinates: Vector2) -> int:
	return cells[cellCoordinates.y][cellCoordinates.x].action

func setCellAction(cellCoordinates: Vector2, cellAction: int):
	cells[cellCoordinates.y][cellCoordinates.x].action = cellAction

func clearCellActions():
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			row[x].action = BoardCell.CellAction.NONE

func overlayCellActions():
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			var tileIndex = -1
			var cellAction = row[x].action
			if cellAction != BoardCell.CellAction.NONE:
				if !cellActionOverlayTileIndexTable.has(cellAction):
					printerr("No tile index for cell action: " + str(cellAction))
				else:
					tileIndex = cellActionOverlayTileIndexTable[cellAction]
			$CellsOverlay.set_cell(x, y, tileIndex)
