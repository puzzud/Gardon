extends Sprite

export(Color) var mainColor
export(Color) var flashColor

var isFlashingColor := false

func _ready():
	pass

func setMainColor(mainColor: Color):
	self.mainColor = mainColor
	
	modulate = mainColor

func setFlashingColor(enable: bool):
	if enable:
		if !isFlashingColor:
			$Timers/FlashTimer.start()
			isFlashingColor = true
			modulate = flashColor
	else:
		$Timers/FlashTimer.stop()
		isFlashingColor = false
		modulate = mainColor

func onFlashTimerTimeout():
	if modulate == mainColor:
		modulate = flashColor
	else:
		modulate = mainColor
