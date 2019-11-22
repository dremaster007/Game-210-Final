extends CanvasLayer

onready var countdown_sprites = ["res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP3.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP2.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP1.png",
								"res://Assets/Graphics/Sprites/SelectionBoxes/SplatterBoiCharacterSelect.png"]

func _ready():
	countdown()

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