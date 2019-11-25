extends KinematicBody2D

const GRAVITY = 35
const ACCELERATION = 100
const MAX_SPEED = 450
const JUMP_HEIGHT = -700

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
onready var player_anim = $Player1IKChain/AnimationPlayer
onready var hitbox_anim = $Attack_Collision/AnimationPlayer

# This allows us to track each player by an ID
export (int) var player_number

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
# ????
var platform_fall_count = 0

var ultimate_fill = 0
var ultimate_max = 100
var can_ultimate = false

var Global = null

func _ready():
	change_state(IDLE)
	Global = find_parent("Global")

func load_textures():
	match player_number:
		1:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP1.png")
		2:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP2.png")
		3:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP3.png")
		4:
			$PlayerIndicator.texture = load("res://Assets/Graphics/Sprites/SelectionBoxes/SelectionBoxesP4.png")

func _physics_process(delta):
	# If we are standing still...
	if is_on_floor():
		if velocity.x < EPSILON and velocity.x > -EPSILON:
			#player_anim.play("%s_idle" % facing_dir)
			velocity.x = 0
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
		platform_fall_count += 1
		$Platform_Fall_Timer.start()
		# Fall through the platform if it is a one way platform
		if current_platform != null and platform_fall_count >= 2:
			if current_platform.is_in_group("one_way_platform"):
				current_platform = null
				position.y += 1
	
	# If we just release down...
	if down_released:
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
			if velocity.x > EPSILON:
				att_direction = "right"
			elif velocity.x < EPSILON:
				att_direction = "left"
			else:
				att_direction = "down"
			if debug_mode["show_state_prints"] == true:
				print("Falling")
		FAST_FALLING:
			if platform_fall_count >= 2:
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
					hitbox_anim.play("%s_air_attack" % att_direction)
				else:
					hitbox_anim.play("down_ground_%s_attack" % facing_dir)
				player_anim.play("%s_leg_sweep" % facing_dir)
			elif att_direction == "neutral":
				hitbox_anim.play("%s_attack" % att_direction)
				player_anim.play("%s_neutral_kick" % facing_dir)
			elif Input.is_action_pressed("left_%s" % player_number) or Input.is_action_pressed("right_%s" % player_number):
				player_anim.play("%s_side_kick" % facing_dir)
				hitbox_anim.play("%s_attack" % att_direction)
			
			if debug_mode["show_state_prints"] == true:
				print("Attack")
		STUNNED:
			can_input = false
			slowing_velocity = true
			yield(get_tree().create_timer(0.75),"timeout")
			can_input = true
			slowing_velocity = false
			
			# Mostly unused for right now
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
			velocity.x = lerp(velocity.x, 0, 0.01)
			if facing_dir == "left":
				velocity.x = -300
			elif facing_dir == "right":
				velocity.x = 300
		"leg_sweep":
			if is_on_floor():
				if facing_dir == "left":
					velocity.x = -400
				elif facing_dir == "right":
					velocity.x = 400
			velocity.x = lerp(velocity.x, 0, 0.1)
		"neutral_kick":
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

func _on_Platform_Fall_Timer_timeout():
	platform_fall_count = 0

#player's state changes to STUNNED when hit and will handle player damage
func take_damage():
	if player_number == 1:
		$HitSound.pitch_scale = 1.5
	if player_number == 2:
		$HitSound.pitch_scale = 0.5
	$HitSound.play()
	change_state(STUNNED)
#	print("hit %s" % player_number)

#sets knockback directions for when the player gets hit
func knockback(type, other_fac_dir):
	match type:
		"side_kick":
			if other_fac_dir == "left":
				velocity.x = -1000
				velocity.y = -300
			elif other_fac_dir == "right":
				velocity.x = 1000
				velocity.y = -300
			slow_percent = 0.08
		"leg_sweep":
			if other_fac_dir == "left":
				velocity.x = -800
				velocity.y = -900
			elif other_fac_dir == "right":
				velocity.x = 800
				velocity.y = -900
			slow_percent = 0.08
		"neutral_kick":
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
				player_area.knockback(next_velocity, facing_dir)
				ultimate_charge(10)

func ultimate_charge(charge_amount):
	ultimate_fill += charge_amount
	if ultimate_fill >= ultimate_max:
		can_ultimate = true

func activate_ultimate():
	match Global.player_picks["player_%s" % player_number]:
		0:
			print("1")
			# Leave paint where the player walks for a limited amount of time.
			# create a bool that is false by default called paint_trail.
			# set it to true when ultimate is used.
			# Add a timer to player scene that will have its time set depending on the type of ultimate.
			# Start timer once ultimate is in use.
			# When in use call a function in process/physics process that will - 
			# - leave paint splatter on or around the players current position for a limited time. 
			# End ultimate once timer runs out of time. 
		1:
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

