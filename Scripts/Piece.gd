extends Node2D
class_name Piece

# warning-ignore:unused_class_variable
export(Vector2) var BoardCellOffset := Vector2(8, 7)

var alive: bool = true

export(int) var teamIndex = 0

# warning-ignore:unused_class_variable
export(int) var movementRange = 7

var movementDirections = [
	Global.DIRECTION_LEFT_UP,
	Global.DIRECTION_UP,
	Global.DIRECTION_RIGHT_UP,
	Global.DIRECTION_LEFT,
	Global.DIRECTION_RIGHT,
	Global.DIRECTION_LEFT_DOWN,
	Global.DIRECTION_DOWN,
	Global.DIRECTION_RIGHT_DOWN
]

var moveDirectionAnimationNames = {
	Global.DIRECTION_LEFT_UP: "moveUp",
	Global.DIRECTION_UP: "moveUp",
	Global.DIRECTION_RIGHT_UP: "moveUp",
	Global.DIRECTION_LEFT: "moveLeft",
	Global.DIRECTION_NONE: "idleUp",
	Global.DIRECTION_RIGHT: "moveRight",
	Global.DIRECTION_LEFT_DOWN: "moveDown",
	Global.DIRECTION_DOWN: "moveDown",
	Global.DIRECTION_RIGHT_DOWN: "moveDown"
}

var activated: bool = false

var moving: bool = false
var attacking: bool = false

var targetPiece: Piece = null

func _ready():
	setTeamIndex(teamIndex)

# warning-ignore:unused_argument
func _process(delta):
	if Global.game.activePiece == self:
		if attacking && targetPiece != null:
			if global_position.distance_to(targetPiece.global_position) < 7.0:
				Global.game.processPieceAttackingPiece(self, targetPiece)
				attacking = false
				targetPiece = null

func setTeamIndex(teamIndex):
	self.teamIndex = teamIndex
	
	$Body.region_rect.position.x = teamIndex * 16

func setActivated(activated: bool):
	self.activated = activated
	
	if activated:
		$AnimationPlayer.play("activate")
		$AudioPlayers/Activate1.play()
	else:
		$AnimationPlayer.play("deactivate")
		$AudioPlayers/Deactivate1.play()

func getMovementDirections():
	return movementDirections

func moveToPosition(position: Vector2):
	moving = true
	
	$MoveTween.interpolate_property(self, "global_position", global_position, position, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()
	
	var moveDirection = Global.getDirectionFromVector(position - global_position)
	
	var moveAnimationName = getAnimationNameFromMovementDirection(moveDirection)
	if $AnimationPlayer.has_animation(moveAnimationName):
		$AnimationPlayer.play(moveAnimationName)
	
	$AudioPlayers/StartMove1.play()

func onMoveTweenAllCompleted():
	moving = false
	
	if Global.game.activePiece == self:
		Global.game.activePiece.setActivated(false)
		Global.game.activePiece = null
	
	Global.game.removeProcessingPiece(self)

func getAnimationNameFromMovementDirection(direction: int):
	return moveDirectionAnimationNames[direction]

func attack(piece):
	attacking = true
	targetPiece = piece
	
	$AudioPlayers/StartAttack1.play()

# warning-ignore:unused_argument
func receiveDamage(damageAmount: float, attacker: Piece):
	if damageAmount == 0.0:
		return
	
	# NOTE: No concept of HP.
	startDying()

func startDying():
	Global.game.addProcessingPiece(self)
	
	$AnimationPlayer.play("dying")
	$Body.visible = false
	$Shadow.visible = false
	
	$GibsParticles.set_emitting(true)
	$GibsParticles.restart()
	
	$AudioPlayers/Hit1.play()

func dyingAnimationFinished():
	alive = false
	
	Global.game.removeProcessingPiece(self)
	
	self.queue_free()

func onAnimationPlayerAnimationFinished(anim_name):
	if anim_name == "dying":
		dyingAnimationFinished()
	elif anim_name == "deactivate":
		if $AnimationPlayer.has_animation("idle"):
			$AnimationPlayer.play("idle")
		elif $AnimationPlayer.has_animation("idleUp"):
			$AnimationPlayer.play("idleUp")
