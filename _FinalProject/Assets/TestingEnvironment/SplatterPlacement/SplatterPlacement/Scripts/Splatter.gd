extends Node2D

# textures of the splatter
var splatter_textures = [load("res://Assets/Graphics/Sprites/Background/splatter_1.png"),
						load("res://Assets/Graphics/Sprites/Background/splatter_2.png"), 
						load("res://Assets/Graphics/Sprites/Background/splatter_3.png"),
						load("res://Assets/Graphics/Sprites/Background/splatter_4.png")]

var is_placed = false # are the sprite officially on the wall?
var type # color of sprite
var score_value = 4 # how much score this sprite node holds

# set all of the textures
func _ready():
	$SpriteHolder/Sprite1.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite2.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite3.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite4.texture = splatter_textures[randi() % 4]

# just set the color value
func start(color_val, color_type):
	for node in $SpriteHolder.get_children():
		node.modulate = color_val
		type = color_type

# checks the score value
func _process(delta):
	check_score_value()

# determines if the score value is 0, then free's it
func check_score_value():
	if score_value == 0:
		queue_free()

# decreases the score value of node
func decrease_score_value(amount):
	score_value -= amount

# just sets is_placed to true
func set_placed():
	is_placed = true

# returns true if the sent node is not in the hierarchy
func is_sprite_null(area, sprite_num):
	if area.get_parent().get_node("SpriteHolder/Sprite%s" % sprite_num) == null:
		return true

func kill_sprite_parts(area, sprite_num):
	pass

func _on_TLCheck_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().is_in_group("player"):
		return
	if area.get_parent().is_in_group("PaintBomb"):
		return
	if area.get_parent().is_placed:
		if area_shape == 0:
			if is_sprite_null(area, "1"):
				return
			area.get_parent().decrease_score_value(1)
			area.get_parent().get_node("SpriteHolder/Sprite1").queue_free()
			area.get_parent().get_node("Check/Col1").call_deferred("queue_free")
		if area_shape == 1:
			if is_sprite_null(area, "2"):
				return
			area.get_parent().decrease_score_value(1)
			area.get_parent().get_node("SpriteHolder/Sprite2").queue_free()
			area.get_parent().get_node("Check/Col2").call_deferred("queue_free")
		if area_shape == 2:
			if is_sprite_null(area, "3"):
				return
			area.get_parent().decrease_score_value(1)
			area.get_parent().get_node("SpriteHolder/Sprite3").queue_free()
			area.get_parent().get_node("Check/Col3").call_deferred("queue_free")
		if area_shape == 3:
			if is_sprite_null(area, "4"):
				return
			area.get_parent().decrease_score_value(1)
			area.get_parent().get_node("SpriteHolder/Sprite4").queue_free()
			area.get_parent().get_node("Check/Col4").call_deferred("queue_free")

func _on_PlaceTimer_timeout():
	set_placed()
