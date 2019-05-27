extends Node
#class_name Global

# warning-ignore:unused_class_variable
var game: Game = null

# warning-ignore:unused_class_variable
var numberOfHumanPlayers: int = 2

func _ready():
	pass

func getDirectionFromVector(vector: Vector2) -> int:
	var direction = Direction.NONE
	
	if vector.x < 0:
		direction = direction | Direction.FLAG_LEFT
	elif vector.x > 0:
		direction = direction | Direction.FLAG_RIGHT
	
	if vector.y < 0:
		direction = direction | Direction.FLAG_UP
	elif vector.y > 0:
		direction = direction | Direction.FLAG_DOWN
	
	return direction
