extends Node2D
class_name BoardCellContent

# warning-ignore:unused_class_variable
export(int) var teamIndex = 0

# warning-ignore:unused_class_variable
export(int) var movementRange = 7

# warning-ignore:unused_class_variable
export(bool) var canAttack = false

# warning-ignore:unused_class_variable
export(bool) var canUsePieces = false

# warning-ignore:unused_class_variable
var alive: bool = true

# warning-ignore:unused_class_variable
var user: BoardCellContent = null

# warning-ignore:unused_class_variable
var piece: Piece = null

const movementDirections = [
	Direction.LEFT_UP,
	Direction.UP,
	Direction.RIGHT_UP,
	Direction.LEFT,
	Direction.RIGHT,
	Direction.LEFT_DOWN,
	Direction.DOWN,
	Direction.RIGHT_DOWN
]

func _ready():
	pass

func initialize():
	pass

func getMovementDirections():
	return movementDirections
