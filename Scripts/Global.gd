extends Node
#class_name Global

const MaximumNumberOfPlayers := 2

# warning-ignore:unused_class_variable
var game: Game = null

enum PlayerType {
	COMPUTER,
	HUMAN
}

var playerTypes = [PlayerType.HUMAN, PlayerType.COMPUTER]

# warning-ignore:unused_class_variable
var numberOfHumanPlayers: int = 0

func _ready():
	numberOfHumanPlayers = 0
	for playerType in playerTypes:
		if playerType == PlayerType.HUMAN:
			numberOfHumanPlayers = numberOfHumanPlayers + 1

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
