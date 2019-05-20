extends Node2D
class_name Piece

const BoardCellOffset := Vector2(8, 7)

export(int) var teamIndex = 0

var activated: bool = false

var moving: bool = false
var attacking: bool = false

var targetPiece: Piece = null

func _ready():
	setTeamIndex(teamIndex)

func _process(delta):
	if Global.game.activePiece == self:
		if attacking && targetPiece != null:
			if global_position.distance_to(targetPiece.global_position) < 7.0:
				Global.game.processPieceAttackingPiece(self, targetPiece)
				attacking = false
				targetPiece = null
				
				#Global.game.endTurn()

func setTeamIndex(teamIndex):
	self.teamIndex = teamIndex
	
	$Body.region_rect.position.x = teamIndex * 16

func setActivated(activated: bool):
	self.activated = activated
	
	if activated:
		$AnimationPlayer.play("activate")
	else:
		$AnimationPlayer.play("deactivate")

func moveToPosition(position: Vector2):
	moving = true
	
	$MoveTween.interpolate_property(self, "global_position", global_position, position, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()

func onMoveTweenAllCompleted():
	moving = false
	
	if Global.game.activePiece == self:
		Global.game.activePiece.setActivated(false)
		Global.game.activePiece = null
		
		#Global.game.endTurn()

func attack(piece):
	attacking = true
	targetPiece = piece
