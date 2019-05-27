extends Node
class_name BoardMiniMaxNode

var score: int = 0

var childNodes = []

var board: Board = null

func initialize(previousBoard: Board):
	board = Board.new()
	board.copy(previousBoard)

