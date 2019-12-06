extends CanvasLayer

onready var countdown_sprites = ["res://Assets/Graphics/Sprites/CountdownArt/countdown_3.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_2.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_1.png",
								"res://Assets/Graphics/Sprites/CountdownArt/countdown_fight.png"]

onready var ultimate_bars = {"red": $Bars/UltimateProgress/RedUltProgress,
							"blue": $Bars/UltimateProgress/BlueUltProgress,
							"green": $Bars/UltimateProgress/GreenUltProgress,
							"yellow": $Bars/UltimateProgress/YellowUltProgress}

onready var painted_bars = {"red": $Bars/AmountPaintedBars/RedProgress,
							"blue": $Bars/AmountPaintedBars/BlueProgress,
							"green": $Bars/AmountPaintedBars/GreenProgress,
							"yellow": $Bars/AmountPaintedBars/YellowProgress}

onready var timer_sprites = ["res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_0.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_1.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_2.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_3.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_4.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_5.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_6.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_7.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_8.png",
							"res://Assets/Graphics/Sprites/UIArt/TimerNumbers/number_9.png"]

var ones_time = 0
var tens_time = 0
var mins_time = 0

var max_paint_value = 0

var game_time = 0

var Global = null
var Level = null

func _ready():
	Global = find_parent("Global")
	Level = find_parent("DragonLevel")
	game_setup()

func game_setup():
	# Here we hide all the bars so that we can only show the ones 
	# that have players attached to them
	$TimerSprites.hide()
	for bar in painted_bars.values():
		bar.hide()
	for bar in ultimate_bars.values():
		bar.hide()
	
	for num in Global.number_of_players:
		var color = ""
		match num:
			0:
				color = "red"
			1:
				color = "blue"
			2:
				color = "green"
			3:
				color = "yellow"
		painted_bars[color].show()
		ultimate_bars[color].show()
	
	# For each color in our bars, we set their values to 0
	for color in ultimate_bars.keys():
		update_hud("ultimate", color, 0)
	for color in painted_bars.keys():
		update_hud("paint", color, 0)
	countdown()
	game_time = Global.game_time
	mins_time = floor(game_time / 60)
	var min_remainder = fmod(game_time, 60)
	tens_time = floor(min_remainder / 10)
	var sec_remainder = fmod(min_remainder, 10)
	ones_time = sec_remainder
	#print("Game Time: ", mins_time, " Minute ", tens_time, ones_time, " Seconds")
	update_clock_sprites()
	

func update_hud(type, color, value):
	for bar in painted_bars.values():
		bar.max_value = max_paint_value
	match type:
		"ultimate":
			ultimate_bars[color].value = value
		"paint":
			painted_bars[color].value = value

func countdown():
	Global.play_sound("StartTimerSFX")
	$CountdownSprite.scale = Vector2(1, 1)
	$CountdownSprite.show()
	$CountdownSprite.texture = load(countdown_sprites[0])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.texture = load(countdown_sprites[1])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.texture = load(countdown_sprites[2])
	yield(get_tree().create_timer(1),"timeout")
	$CountdownSprite.scale = Vector2(1.5, 1.5)
	$CountdownSprite.texture = load(countdown_sprites[3])
	Global.play_sound("FightSFX")
	yield(get_tree().create_timer(0.5),"timeout")
	$CountdownSprite.hide()
	$TimerSprites.show()
	$PlayTimer.start()
	$SecondTimer.start()

func _on_PlayTimer_timeout():
	if game_time == 0:
		$SecondTimer.stop()
		$PlayTimer.stop()
		Level.game_over()
		yield(get_tree().create_timer(3),"timeout")
		Global.change_scene("picking_screen")
	else:
		game_time -= 1
		if game_time == 5:
			Global.play_sound("CountdownTimerSFX")

func update_clock_sprites():
	$TimerSprites/PlayTimerMins.texture = load(timer_sprites[mins_time])
	$TimerSprites/PlayTimerTens.texture = load(timer_sprites[tens_time])
	$TimerSprites/PlayTimerOnes.texture = load(timer_sprites[ones_time])
	#print(mins_time, ":", tens_time, ones_time)

func _on_SecondTimer_timeout():
	ones_time -= 1
	if ones_time < 0:
		tens_time -= 1
		ones_time = 9
		if tens_time < 0:
			mins_time -= 1
			tens_time = 5
			if mins_time < 0:
				ones_time = 0
				tens_time = 0
				mins_time = 0
	update_clock_sprites()