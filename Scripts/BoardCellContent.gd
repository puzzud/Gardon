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

# warning-ignore:unused_class_variable
const moveDirectionAnimationNameSuffixes = {
	Direction.LEFT_UP: "Up",
	Direction.UP: "Up",
	Direction.RIGHT_UP: "Up",
	Direction.LEFT: "Left",
	Direction.NONE: "Down",
	Direction.RIGHT: "Right",
	Direction.LEFT_DOWN: "Down",
	Direction.DOWN: "Down",
	Direction.RIGHT_DOWN: "Down"
}

# warning-ignore:unused_class_variable
var activated: bool = false

# warning-ignore:unused_class_variable
var targetPiece: BoardCellContent = null

func _ready():
	pass
