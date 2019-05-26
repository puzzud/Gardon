extends Node
#class_name Global

const DIRECTION_FLAG_LEFT = 0x01
const DIRECTION_FLAG_RIGHT = 0x02
const DIRECTION_FLAG_UP = 0x04
const DIRECTION_FLAG_DOWN = 0x08

const DIRECTION_LEFT_UP = DIRECTION_FLAG_LEFT | DIRECTION_FLAG_UP
const DIRECTION_UP = DIRECTION_FLAG_UP
const DIRECTION_RIGHT_UP = DIRECTION_FLAG_RIGHT | DIRECTION_FLAG_UP
const DIRECTION_LEFT = DIRECTION_FLAG_LEFT
const DIRECTION_NONE = 0
const DIRECTION_RIGHT = DIRECTION_FLAG_RIGHT
const DIRECTION_LEFT_DOWN = DIRECTION_FLAG_LEFT | DIRECTION_FLAG_DOWN
const DIRECTION_DOWN = DIRECTION_FLAG_DOWN
const DIRECTION_RIGHT_DOWN = DIRECTION_FLAG_RIGHT | DIRECTION_FLAG_DOWN

# warning-ignore:unused_class_variable
var game: Game = null

# warning-ignore:unused_class_variable
var numberOfHumanPlayers: int = 2

func _ready():
	pass

func getDirectionFromVector(vector: Vector2) -> int:
	var direction = DIRECTION_NONE
	
	if vector.x < 0:
		direction = direction | DIRECTION_FLAG_LEFT
	elif vector.x > 0:
		direction = direction | DIRECTION_FLAG_RIGHT
	
	if vector.y < 0:
		direction = direction | DIRECTION_FLAG_UP
	elif vector.y > 0:
		direction = direction | DIRECTION_FLAG_DOWN
	
	return direction
