extends KinematicBody2D

const GRAVITY = 35
const ACCELERATION = 100
const MAX_SPEED = 450
const JUMP_HEIGHT = -700

export (PackedScene) var PaintBomb

# This is a dictionary that holds our debug states
var debug_mode = {"show_state_prints": false, "show_collision_shapes": false}

# Bool to hold if can process inputs
var can_input = true

# This is a String that tracks what velocity we will send it.
# This is mostly used for animations that should have a set velocity.
var next_velocity = null
var slowing_velocity = false
var slow_percent = 0
var attacking = false

# Variables that hold our animations players. This is for ease of access.
var player_anim = null
onready var hitbox_anim = $Attack_Collision/AnimationPlayer

export (PackedScene) var IK_chain_0
export (PackedScene) var IK_chain_1
export (PackedScene) var IK_chain_2
export (PackedScene) var IK_chain_3
export (PackedScene) var IK_chain_4
export (PackedScene) var IK_chain_5
export (PackedScene) var IK_chain_6
export (PackedScene) var IK_chain_7

# This allows us to track each player by an ID
export (int) var player_number
var character = 0
var player_color = ""

var velocity = Vector2()

# These are our states that we could be in.
enum {IDLE,WALK,RUN,JUMP,FALLING,FAST_FALLING,ATTACK,STUNNED}

# This is a number that is for all intents and purposes, zero.
const EPSILON = 0.5

var max_jumps = 3
var current_jumps = 0

# Bool that allows us to check if we can fall through a platform
var platform_fall = false

# This holds the platform that we are currently standing on
var current_platform = null

# This tells us what state we are in.
var state 

# This is which direction we are attacking
var att_direction = ""
# This is which direction we are facing
var facing_dir = "right"

var ultimate_fill = 0
var ultimate_max = 100
var can_ultimate = false

var bomb_pos = Vector2()

var Global = null
var Level = null

func _ready():
	Global = find_parent("Global")
	Level = find_parent("DragonLevel")
	hitbox_anim.play("null")

func load_textures(character_num):
	print("Player%s " % player_number, "picked character ", character_num)
	var i = null
	character = character_num
	match character_num:
		0:
			i = IK_chain_0.instance()
		1:
			i = IK_chain_1.instance()
		2:
			i = IK_chain_2.instance()
		3:
			i = IK_chain_3.instance()
		4:
			i = IK_chain_4.instance()
		5:
			i = IK_chain_5.instance()
		6:
			i = IK_chain_6.instance()
		7:
			i = IK_chain_7.instance()
	
	player_anim = i.find_node("AnimationPlayer")
	player_anim.connect("animation_started", self, "_on_AnimationPlayer_animation_started")
	player_anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	add_child(i)
	player_anim.play("%s_idle" % facing_dir)
	
	match player_number:
		1:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/UIArt/Indicators/red_ind.png")
		2:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/UIArt/Indicators/blue_ind.png")
		3:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/UIArt/Indicators/green_ind.png")
		4:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/UIArt/Indicators/yellow_ind.png")
	#change_state(IDLE)

func _physics_process(delta):
	# If we are standing still...
	if is_on_floor():
		if velocity.x < EPSILON and velocity.x > -EPSILON:
			#player_anim.play("%s_idle" % facing_dir)
			velocity.x = 0
			
			# might be causing players to be unable to move at certain points
			change_state(IDLE)
			
		current_jumps = 0
	
	if slowing_velocity == false:
		slow_velocity(0)
	elif slowing_velocity == true:
		slow_velocity(slow_percent)
	
	get_input()
	
	# If we are falling
	if state == JUMP and velocity.y > EPSILON:
		change_state(FALLING)
	
	# Adding gravity to our velocity
	# If we are fast falling, allow us to drop faster,
	# otherwise, apply gravity normally
	if state == FAST_FALLING:
		velocity.y += GRAVITY * 1.5
		velocity.y = min(velocity.y, 750)
	else:
		velocity.y += GRAVITY
		velocity.y = min(velocity.y, 500)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	# constantly check if we are supposed to be setting our velocity manually
	set_velocity(next_velocity)

func get_input():
	# If we can't check for inputs:
	if !can_input:
		#print("help")
		return
	
	#------------------------------------------------------------
	# HERE ARE SOME SHORTCUTS FOR INPUTS
	var left = Input.is_action_pressed("left_%s" % player_number)
	var left_released = Input.is_action_just_released("left_%s" % player_number)
	var right = Input.is_action_pressed("right_%s" % player_number)
	var right_released = Input.is_action_just_released("right_%s" % player_number)
	var up = Input.is_action_pressed("up_%s" % player_number)
	var down = Input.is_action_pressed("down_%s" % player_number)
	var down_just_pressed = Input.is_action_just_pressed("down_%s" % player_number)
	var down_released = Input.is_action_just_released("down_%s" % player_number)
	var jump = Input.is_action_just_pressed("jump_%s" % player_number)
	var attack = Input.is_action_just_pressed("attack_%s" % player_number)
	var ultimate = Input.is_action_just_pressed("ultimate_%s" % player_number)
	#------------------------------------------------------------
	
	#----------------------------------------------------
	# DEBUG CONTROLS
	if Input.is_action_just_pressed("toggle_state_print"):
		debug_mode["show_state_prints"] = !debug_mode["show_state_prints"]
		print("debug_mode: ", debug_mode)
	
	# BROKEN: CURRENTLY DOESN'T SHOW COLLISIONS
	if Input.is_action_just_pressed("toggle_collision_shapes"):
		debug_mode["show_collision_shapes"] = !debug_mode["show_collision_shapes"]
		print("debug_mode: ", debug_mode)
	#----------------------------------------------------
	
	# If we are moving left...
	if left and !right:
		att_direction = "left"
		facing_dir = "left"
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		# Gradually speed us up until our max speed
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	# else if we are moving right...
	elif right and !left:
		att_direction = "right"
		facing_dir = "right"
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		
		# Gradually speed us up until our max speed
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	else:
		# This slows down our character from their current velocity to 0, 20% each frame
		velocity.x = lerp(velocity.x, 0, 0.2)
	
	# If we stop moving...
	if left_released or right_released:
		change_state(IDLE)
	
	# If we jump...
	if jump:
		if current_jumps < max_jumps:
			change_state(JUMP)
	
	# If we hold down...
	if down:
		set_collision_mask_bit(2, false)
#		if state == JUMP or state == FALLING or state == FAST_FALLING:
#			att_direction = "down"
		if state != FAST_FALLING:
			if !is_on_floor():
				# If we are moving upwards stop our velocity
				if velocity.y < 0:
					velocity.y = 0
				change_state(FAST_FALLING)
		att_direction = "down"
	
	# If we jsut press down...
	if down_just_pressed:
		# Fall through the platform if it is a one way platform
		if current_platform != null:
			if current_platform.is_in_group("one_way_platform"):
				yield(get_tree().create_timer(0.1),"timeout")
				current_platform = null
				position.y += 1
	
	# If we just release down...
	if down_released:
		set_collision_mask_bit(2, true)
		att_direction = "neutral"
		platform_fall = false
		if !is_on_floor():
			change_state(FALLING)
		else:
			change_state(IDLE)
	
	# If we press up...
	if up:
		att_direction = "neutral"
	
	# If we attack...
	if attack:
		change_state(ATTACK)
	
	if ultimate:
		if can_ultimate:
			activate_ultimate()

# This function allows us to change states
func change_state(new_state):
	attacking = false
	state = new_state
	match state:
		IDLE:
			platform_fall = false
			att_direction = "neutral"
			hitbox_anim.play("null")
			# WE NEED THIS COMMENT LATER
			#Global.player_picks("Player_%s" % player_number)
			player_anim.play("%s_idle" % facing_dir)
			if debug_mode["show_state_prints"] == true:
				print("idle")
		WALK:
			player_anim.play("%s_walking" % facing_dir)
			if debug_mode["show_state_prints"] == true:
				print("Walk")
		RUN:
			if debug_mode["show_state_prints"] == true:
				print("run")
		JUMP:
			#Input.start_joy_vibration(0, 0.5, 0.1, 0.4)
			if current_jumps == 0:
				player_anim.play("%s_jump" % facing_dir)
			else:
				player_anim.play("%s_jump_flip" % facing_dir)
			velocity.y = JUMP_HEIGHT
			current_jumps += 1
			att_direction = "neutral"
			if debug_mode["show_state_prints"] == true:
				print("jump")
		FALLING:
			player_anim.play("%s_falling" % facing_dir)
			if velocity.x > EPSILON:
				att_direction = "right"
			elif velocity.x < EPSILON:
				att_direction = "left"
			else:
				att_direction = "down"
			if debug_mode["show_state_prints"] == true:
				print("Falling")
		FAST_FALLING:
			player_anim.play("%s_falling" % facing_dir)
			platform_fall = true
			att_direction = "down"
			if debug_mode["show_state_prints"] == true:
				print("Fast Falling")
		ATTACK:
			attacking = true
			if !is_on_floor():
				if !Input.is_action_pressed("up_%s" % player_number):
					if att_direction != "left" and att_direction != "right":
						att_direction = "down"
			
			# Prioritize down attacks first, then neutral/up attacks,
			# then left/right attacks.
			if att_direction == "down":
				if velocity.y > EPSILON:
					hitbox_anim.play(str(character) + "_%s_air_attack" % att_direction)
					#hitbox_anim.play("%s_air_attack" % att_direction)
				else:
					hitbox_anim.play(str(character) + "_down_ground_%s_attack" % facing_dir)
					#hitbox_anim.play("down_ground_%s_attack" % facing_dir)
				player_anim.play("%s_leg_sweep" % facing_dir)
			elif att_direction == "neutral":
				hitbox_anim.play(str(character) + "_%s_attack" % att_direction)
				#hitbox_anim.play("%s_attack" % att_direction)
				player_anim.play("%s_neutral_kick" % facing_dir)
			elif Input.is_action_pressed("left_%s" % player_number) or Input.is_action_pressed("right_%s" % player_number):
				player_anim.play("%s_side_kick" % facing_dir)
				hitbox_anim.play(str(character) + "_%s_attack" % att_direction)
				#hitbox_anim.play("%s_attack" % att_direction)
			
			if debug_mode["show_state_prints"] == true:
				print("Attack")
		STUNNED:
			can_input = false
			slowing_velocity = true
			yield(get_tree().create_timer(0.75),"timeout")
			can_input = true
			slowing_velocity = false
			
			att_direction = "neutral"
			if debug_mode["show_state_prints"] == true:
				print("Stunned")

# This allows us to manually set the players velocity during attacks and
# after they have been attacked and are currently stunned.
func set_velocity(type):
	if type == null:
		return
	match type:
		"side_kick":
			match character:
				0:
					velocity.x = lerp(velocity.x, 0, 0.01)
					if facing_dir == "left":
						velocity.x = -200
					elif facing_dir == "right":
						velocity.x = 200
				1:
					velocity.x = lerp(velocity.x, 0, 0.01)
					if facing_dir == "left":
						velocity.x = -30
					elif facing_dir == "right":
						velocity.x = 30
		"leg_sweep":
			match character:
				0:
					if is_on_floor():
						if facing_dir == "left":
							velocity.x = -400
						elif facing_dir == "right":
							velocity.x = 400
						velocity.x = lerp(velocity.x, 0, 0.1)
				1:
					if is_on_floor():
						if facing_dir == "left":
							velocity.x = -150
						elif facing_dir == "right":
							velocity.x = 150
						velocity.x = lerp(velocity.x, 0, 0.1)
		"neutral_kick":
			match character:
				0:
					velocity.x = lerp(velocity.x, 0, 0.2)
				1:
					velocity.x = lerp(velocity.x, 0, 0.2)

func _on_PlatformCollisionArea_body_entered(body):
	current_platform = body

func _on_PlatformCollisionArea_body_exited(body):
	current_platform = null

func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "%s_side_kick" % facing_dir:
		next_velocity = "side_kick"
		can_input = false
	if anim_name == "%s_leg_sweep" % facing_dir:
		next_velocity = "leg_sweep"
		can_input = false
	if anim_name == "%s_neutral_kick" % facing_dir:
		next_velocity = "neutral_kick"
		can_input = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "%s_side_kick" % facing_dir:
		can_input = true
		next_velocity = null
	if anim_name == "%s_leg_sweep" % facing_dir:
		can_input = true
		next_velocity = null
	if anim_name == "%s_neutral_kick" % facing_dir:
		player_anim.play("%s_idle" % facing_dir)
		can_input = true
		next_velocity = null
	if anim_name == "null":
		return
	else:
		hitbox_anim.play("null")
		if att_direction != "down":
			att_direction = "neutral"

#player's state changes to STUNNED when hit and will handle player damage
func take_damage():
	if player_number == 1:
		$HitSound.pitch_scale = 1.5
	if player_number == 2:
		$HitSound.pitch_scale = 0.5
	$HitSound.play()
	change_state(STUNNED)
	ultimate_charge(2)
#	print("hit %s" % player_number)

#sets knockback directions for when the player gets hit
func knockback(type, other_fac_dir, other_character):
	match type:
		"side_kick":
			match other_character:
				0:
					if other_fac_dir == "left":
						velocity.x = -1000
						velocity.y = -300
					elif other_fac_dir == "right":
						velocity.x = 1000
						velocity.y = -300
					slow_percent = 0.08
				1: 
					if other_fac_dir == "left":
						velocity.x = -1000
						velocity.y = -300
					elif other_fac_dir == "right":
						velocity.x = 1000
						velocity.y = -300
					slow_percent = 0.08
		"leg_sweep":
			match other_character:
				0:
					if other_fac_dir == "left":
						velocity.x = -800
						velocity.y = -1000
					elif other_fac_dir == "right":
						velocity.x = 800
						velocity.y = -1000
					slow_percent = 0.08
				1:
					if other_fac_dir == "left":
						velocity.x = 500
						velocity.y = -900
					elif other_fac_dir == "right":
						velocity.x = -500
						velocity.y = -900
					slow_percent = 0.08
		"neutral_kick":
			match other_character:
				0:
					if other_fac_dir == "left":
						velocity.x = -400
						velocity.y = -900
					elif other_fac_dir == "right":
						velocity.x = 400
						velocity.y = -900
					slow_percent = 0.08
				1:
					if other_fac_dir == "left":
						velocity.x = -400
						velocity.y = -900
					elif other_fac_dir == "right":
						velocity.x = 400
						velocity.y = -900
					slow_percent = 0.08
	slowing_velocity = true

func slow_velocity(percent):
	velocity.x = lerp(velocity.x, 0, percent)
	velocity.y = lerp(velocity.y, 0, percent * 0.5)

#detects player collision with the attack collision 
#will only react to opposing player collision and call their take_damage function
#calls opposing players knockback function on attack collision
func _on_Attack_Collision_area_entered(area):
	if attacking:
		if area.is_in_group("player_hit_box"):
			var player_area = area.get_parent()
			if player_area.player_number != player_number:
				find_parent("DragonLevel").place_paint(player_color, player_area.position)
				player_area.take_damage()
				player_area.knockback(next_velocity, facing_dir, character)
				ultimate_charge(10)

func ultimate_charge(charge_amount):
	ultimate_fill += charge_amount
	Level.update_ult(player_color, ultimate_fill)
	if ultimate_fill >= ultimate_max:
		can_ultimate = true

func activate_ultimate():
	can_ultimate = false
	ultimate_fill = 0
	ultimate_charge(0)
	match Global.player_picks["player_%s" % player_number]:
		0:
			$UltDuration.wait_time = 5
			$UltDuration.start()
			$UltTimer.wait_time = 0.2
			$UltTimer.start()
			# Leave paint where the player walks for a limited amount of time.
			# create a bool that is false by default called paint_trail.
			# set it to true when ultimate is used.
			# Add a timer to player scene that will have its time set depending on the type of ultimate.
			# Start timer once ultimate is in use.
			# When in use call a function in process/physics process that will - 
			# - leave paint splatter on or around the players current position for a limited time. 
			# End ultimate once timer runs out of time.
		1:
			bomb_pos = position
			$UltDuration.wait_time = 5
			$UltDuration.start()
			$UltTimer.wait_time = 5
			$UltTimer.start()
			
			#Adds a rigidbody PaintBomb instance to the scene 
#			var pcb = PaintBomb.instance()
#			pcb.global_transform = global_transform
#			var dl = get_parent().get_parent()
#			dl.add_child(pcb)
			print("2")
			# Paint Can Bomb that leaves a large splat of paint where it explodes. 
			# Create a Paint Can scene with a large Area2D around it. 
			# Add a Timer to the Paint Can scene with 2? seconds of wait time. 
			# Add script to Paint Can scene.
			# When Timer expires call explode function. 
			# On explosion leave a large splatter of paint on the background (Sprite or Paritcle effect). 
			# When player activates ultimate spawn Paint Can at set position2D - 
			# - and give it a velocity depending on the direction the player is facing. 
		2:
			print("3")

func ultimate_active():
	match Global.player_picks["player_%s" % player_number]:
		0:
			Level.place_paint(player_color, Vector2(position.x, position.y))
		1:
			for i in 50:
				Level.place_paint(player_color, Vector2(bomb_pos.x + rand_range(-200, 200), bomb_pos.y + rand_range(-200, 200)))

# This is for ults that last a set amount of time
func _on_UltDuration_timeout():
	$UltTimer.stop()

# This is for ults that have to be checked every x seconds
func _on_UltTimer_timeout():
	ultimate_active()

func disable_attack_collisions(is_disabled):
	print("is_disabled = ", is_disabled)
	$Attack_Collision/CollisionShape2D.call_deferred("set", "disabled", is_disabled)
