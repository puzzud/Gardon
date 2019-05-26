extends Node
class_name BoardCell

enum CellAction {
	NONE = -1,
	ACTIVATE,
	ATTACK,
	USE
}

var content: Piece = null
var action: int = CellAction.NONE

func _ready():
	pass
