extends CanvasLayer

onready var countdown_sprites = ["res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP3.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP2.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP1.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SplatterBoiCharacterSelect.png"]

var ultimate_bars = {"red": $BottomLeft/UltimateProgress/RedUltProgress,
					"blue": $BottomLeft/UltimateProgress/BlueUltProgress,
					"green": $BottomLeft/UltimateProgress/GreenUltProgress,
					"yellow": $BottomLeft/UltimateProgress/YellowUltProgress}

var painted_bars = {"red": $BottomLeft/AmountPaintedBars/RedProgress,
					"blue": $BottomLeft/AmountPaintedBars/BlueProgress,
					"green": $BottomLeft/AmountPaintedBars/GreenProgress,
					"yellow": $BottomLeft/AmountPaintedBars/YellowProgress}

func _ready():
	countdown()

func updated_hud(type, color, value):
	match type:
		"ultimate":
			ultimate_bars[color].value = value
		"paint":
			painted_bars[color].value = value

func countdown():
	$CountdownSprite.show()
	$CountdownSprite.texture = load(countdown_sprites[0])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.texture = load(countdown_sprites[1])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.texture = load(countdown_sprites[2])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.texture = load(countdown_sprites[3])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.hide()