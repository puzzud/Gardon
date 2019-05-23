extends Node2D
class_name Piece

export(bool) var canUsePieces = false

# warning-ignore:unused_class_variable
export(Vector2) var BoardCellOffset := Vector2(8, 7)

var alive: bool = true

var user: Piece = null

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
	if Global.game.getActivePiece() == self:
		if attacking && targetPiece != null:
			if global_position.distance_to(targetPiece.global_position) < 7.0:
				Global.game.processPieceAttackingPiece(self, targetPiece)
				attacking = false
				targetPiece = null
				
				if user != null:
					Global.game.setPieceActivated(user, false, false)
					user = null

func setTeamIndex(teamIndex):
	self.teamIndex = teamIndex
	
	$Body.region_rect.position.x = teamIndex * 16

func setActivated(activated: bool):
	self.activated = activated
	
	var audioPlaybackPosition = 0.0
	
	if activated:
		$AnimationPlayer.play("activate")
		
		if $AudioPlayers/Deactivate1.playing:
			audioPlaybackPosition = $AudioPlayers/Deactivate1.get_playback_position()
			$AudioPlayers/Deactivate1.stop()
			
			audioPlaybackPosition = $AudioPlayers/Activate1.stream.get_length() - audioPlaybackPosition
			if audioPlaybackPosition < 0.0:
				audioPlaybackPosition = 0.0
		
		$AudioPlayers/Activate1.play(audioPlaybackPosition)
	else:
		$AnimationPlayer.play("deactivate")
		
		if $AudioPlayers/Activate1.playing:
			audioPlaybackPosition = $AudioPlayers/Activate1.get_playback_position()
			$AudioPlayers/Activate1.stop()
			
			audioPlaybackPosition = $AudioPlayers/Deactivate1.stream.get_length() - audioPlaybackPosition
			if audioPlaybackPosition < 0.0:
				audioPlaybackPosition = 0.0
			
		$AudioPlayers/Deactivate1.play(audioPlaybackPosition)

func getMovementDirections():
	return movementDirections

func moveToPosition(position: Vector2):
	moving = true
	
	if user != null:
		Global.game.setPieceActivated(user, false, false)
		user = null
	
	$MoveTween.interpolate_property(self, "global_position", global_position, position, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()
	
	var moveDirection = Global.getDirectionFromVector(position - global_position)
	
	var moveAnimationName = getAnimationNameFromMovementDirection(moveDirection)
	if $AnimationPlayer.has_animation(moveAnimationName):
		$AnimationPlayer.play(moveAnimationName)
	
	$AudioPlayers/StartMove1.play()

func onMoveTweenAllCompleted():
	moving = false
	
	var activePiece = Global.game.getActivePiece()
	if activePiece == self:
		Global.game.setPieceActivated(self, false, false) # NOTE: Call this instead of setActivated.
		Global.game.addProcessingPiece(self) # Add processing piece to track deactivation process.
	
	Global.game.removeProcessingPiece(self) # Remove processing piece to end move process.

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
		Global.game.removeProcessingPiece(self)
		
		if $AnimationPlayer.has_animation("idle"):
			$AnimationPlayer.play("idle")
		elif $AnimationPlayer.has_animation("idleUp"):
			$AnimationPlayer.play("idleUp")
