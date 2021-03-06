extends Node2D
class_name Piece

# warning-ignore:unused_class_variable
export(Vector2) var BoardCellOffset := Vector2(8, 7)

var boardCellContent = null

var moving: bool = false

var attacking: bool = false

var activated: bool = false

var targetPiece: Piece = null

const moveDirectionAnimationNameSuffixes = {
	Direction.LEFT_UP: "Up",
	Direction.UP: "Up",
	Direction.RIGHT_UP: "Up",
	Direction.LEFT: "Left",
	Direction.NONE: "Down",
	Direction.RIGHT: "Right",
	Direction.LEFT_DOWN: "Down",
	Direction.DOWN: "Down",
	Direction.RIGHT_DOWN: "Down"
}

func _ready():
	setTeamIndex(boardCellContent.teamIndex)

# warning-ignore:unused_argument
func _process(delta):
	if Global.game.getActivePiece() == self:
		if attacking && targetPiece != null:
			if global_position.distance_to(targetPiece.global_position) < 7.0:
				Global.game.processPieceAttackingPiece(self, targetPiece)
				attacking = false
				targetPiece = null

# warning-ignore:unused_argument
func setTeamIndex(teamIndex):
	pass

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

func setPosition(position: Vector2):
	global_position = position

func moveToPosition(position: Vector2):
	moving = true
	
	$MoveTween.interpolate_property(self, "global_position", global_position, position, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()
	
	var moveDirection = Global.getDirectionFromVector(position - global_position)
	
	var moveAnimationName = "move" + getAnimationNameSuffixFromMovementDirection(moveDirection)
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

func getAnimationNameSuffixFromMovementDirection(direction: int):
	return moveDirectionAnimationNameSuffixes[direction]

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
	Global.game.removeProcessingPiece(self)
	
	self.queue_free()

func onAnimationPlayerAnimationFinished(anim_name):
	if anim_name == "dying":
		dyingAnimationFinished()
	elif anim_name == "deactivate":
		Global.game.removeProcessingPiece(self)
		
		onDeactivationFinished()

func onDeactivationFinished():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
