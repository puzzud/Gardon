extends Node
class_name Direction

const FLAG_LEFT = 0x01
const FLAG_RIGHT = 0x02
const FLAG_UP = 0x04
const FLAG_DOWN = 0x08

const LEFT_UP = FLAG_LEFT | FLAG_UP
const UP = FLAG_UP
const RIGHT_UP = FLAG_RIGHT | FLAG_UP
const LEFT = FLAG_LEFT
const NONE = 0
const RIGHT = FLAG_RIGHT
const LEFT_DOWN = FLAG_LEFT | FLAG_DOWN
const DOWN = FLAG_DOWN
const RIGHT_DOWN = FLAG_RIGHT | FLAG_DOWN

func _ready():
	pass
