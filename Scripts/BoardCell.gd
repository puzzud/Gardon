extends Node
class_name BoardCell

enum CellAction {
	NONE = -1,
	ACTIVATE,
	DEACTIVATE,
	ATTACK,
	USE
}

var content: Piece = null
var action: int = CellAction.NONE

func _ready():
	pass

func clear():
	content = null
	action = CellAction.NONE
