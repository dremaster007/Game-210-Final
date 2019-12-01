extends CanvasLayer

onready var timer_sprites = []

onready var countdown_sprites = ["res://Assets/Graphics/Sprites/CountdownArt/countdown_3.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_2.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_1.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_fight.png"]

onready var ultimate_bars = {"red": $BottomLeft/UltimateProgress/RedUltProgress,
							"blue": $BottomLeft/UltimateProgress/BlueUltProgress,
							"green": $BottomLeft/UltimateProgress/GreenUltProgress,
							"yellow": $BottomLeft/UltimateProgress/YellowUltProgress}

onready var painted_bars = {"red": $BottomLeft/AmountPaintedBars/RedProgress,
							"blue": $BottomLeft/AmountPaintedBars/BlueProgress,
							"green": $BottomLeft/AmountPaintedBars/GreenProgress,
							"yellow": $BottomLeft/AmountPaintedBars/YellowProgress}

var max_paint_value = 0

var game_time = 0

func _ready():
	$PlayTimerText.hide()
	for color in ultimate_bars.keys():
		update_hud("ultimate", color, 0)
	for color in painted_bars.keys():
		update_hud("paint", color, 0)
	countdown()

func update_hud(type, color, value):
	for bar in $BottomLeft/AmountPaintedBars.get_children():
		bar.max_value = max_paint_value
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
	yield(get_tree().create_timer(0.5),"timeout")
	$CountdownSprite.hide()
	game_time = 12
	$PlayTimerText.text = str(game_time)
	$PlayTimerText.show()
	$PlayTimer.start()

func _on_PlayTimer_timeout():
	game_time -= 1
	$PlayTimerText.text = str(game_time)
