extends KinematicBody2D

const GRAVITY = 35
const ACCELERATION = 100
const MAX_SPEED = 450
const JUMP_HEIGHT = -700

var debug_mode = {"show_state_prints": false, "show_collision_shapes": false}

onready var player_anim = $Player1IKChain/AnimationPlayer

export (int) var player_number

var velocity = Vector2()
var dodge_velocity = Vector2()

enum {IDLE,WALK,RUN,JUMP,FALLING,FAST_FALLING,ATTACK,STUNNED}

const EPSILON = 0.001

var max_jumps = 3
var current_jumps = 0
var platform_fall = false

var current_platform = null

onready var kbt = $KnockbackTween

var state 
var att_direction = ""
var facing_dir = "Right"
var platform_fall_count = 0

func _ready():
	change_state(IDLE)

func _physics_process(delta):
	if is_on_floor():
		current_jumps = 0
	get_input()
	
	if state == JUMP and velocity.y > EPSILON:
		change_state(FALLING)
	
	if state == FAST_FALLING:
		velocity.y += GRAVITY * 1.5
		velocity.y = min(velocity.y, 750)
	else:
		velocity.y += GRAVITY
		velocity.y = min(velocity.y, 500)
	
	velocity = move_and_slide(velocity, Vector2.UP)

func get_input():
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
	#------------------------------------------------------------
	
	var friction = false
	
	#----------------------------------------------------
	# DEBUG CONTROLS
	if Input.is_action_just_pressed("toggle_state_print"):
		debug_mode["show_state_prints"] = !debug_mode["show_state_prints"]
		print("debug_mode: ", debug_mode)
	
	# CURRENTLY DOESN'T SHOW COLLISIONS
	if Input.is_action_just_pressed("toggle_collision_shapes"):
		debug_mode["show_collision_shapes"] = !debug_mode["show_collision_shapes"]
		print("debug_mode: ", debug_mode)
	#----------------------------------------------------
	
	if left:
		att_direction = "Left"
		facing_dir = "Left"
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	elif right:
		att_direction = "Right"
		facing_dir = "Right"
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	else:
		friction = true
		# This slows down our character from their current velocity to 0, 20% each frame
		velocity.x = lerp(velocity.x, 0, 0.2)
	
	if left_released or right_released:
		if is_on_floor():
			change_state(IDLE)
	
	if jump:
		if current_jumps < max_jumps:
			change_state(JUMP)
	
	if down:
		if state == JUMP or state == FALLING or state == FAST_FALLING:
			att_direction = "Down"
		if state != FAST_FALLING:
			if !is_on_floor():
				if velocity.y < 0:
					velocity.y = 0
				change_state(FAST_FALLING)
		att_direction = "Down"
	
	if down_just_pressed:
		platform_fall_count += 1
		$Platform_Fall_Timer.start()
		if current_platform != null and platform_fall_count >= 2:
			if current_platform.is_in_group("one_way_platform"):
				current_platform = null
				position.y += 1
	
	if down_released:
		platform_fall = false
		if !is_on_floor():
			change_state(FALLING)
		else:
			change_state(IDLE)
	
	if up:
		att_direction = "Neutral"
	
	if attack:
		change_state(ATTACK)

#var current_speed = velocity.x 
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			platform_fall = false
			att_direction = "Neutral"
			$Attack_Collision/AnimationPlayer.play("Attack_Null")
			player_anim.play("idle")
			if debug_mode["show_state_prints"] == true:
				print("idle")
		WALK:
			if player_anim.current_animation == "walking":
				pass
			else:
				player_anim.play("walking")
			if debug_mode["show_state_prints"] == true:
				print("Walk")
		RUN:
			if debug_mode["show_state_prints"] == true:
				print("run")
		JUMP:
			if current_jumps == 0:
				player_anim.play("jump")
			else:
				if facing_dir == "Right":
					player_anim.play("jump_flip")
				elif facing_dir == "Left":
					player_anim.play_backwards("jump_flip")
			velocity.y = JUMP_HEIGHT
			current_jumps += 1
			att_direction = "Neutral"
			if debug_mode["show_state_prints"] == true:
				print("jump")
		FALLING:
			if velocity.x > EPSILON:
				att_direction = "Right"
			elif velocity.x < EPSILON:
				att_direction = "Left"
			else:
				att_direction = "Down"
			if debug_mode["show_state_prints"] == true:
				print("Falling")
		FAST_FALLING:
			if platform_fall_count >= 2:
				platform_fall = true
			att_direction = "Down"
			if debug_mode["show_state_prints"] == true:
				print("Fast Falling")
		ATTACK:
#			velocity.x = 0
			if velocity.y > EPSILON and !Input.is_action_pressed("up_%s" % player_number) and att_direction != "Left" and att_direction != "Right":
				att_direction = "Down"
			if att_direction == "Down": 
				if velocity.y > EPSILON:
					$Attack_Collision/AnimationPlayer.play("Attack_Down")
				elif facing_dir == "Left":
					$Attack_Collision/AnimationPlayer.play("Down_Neutral_Left")
				elif facing_dir == "Right":
					$Attack_Collision/AnimationPlayer.play("Down_Neutral_Right")
			if att_direction == "Neutral":
				$Attack_Collision/AnimationPlayer.play("Attack_Neutral") 
				player_anim.play("neutral_kick")
			if att_direction == "Left":
				$Attack_Collision/AnimationPlayer.play("Attack_Left")
			if att_direction == "Right":
				player_anim.play("side_kick")
				$Attack_Collision/AnimationPlayer.play("Attack_Right")
#			yield(get_tree().create_timer(1.5), "timeout")
#			velocity.x = current_speed
			if debug_mode["show_state_prints"] == true:
				print("Attack")
		STUNNED:
			att_direction = "Neutral"
			if debug_mode["show_state_prints"] == true:
				print("Stunned")

func _on_Area2D_body_entered(body):
	current_platform = body

func _on_Area2D_body_exited(body):
	current_platform = null

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack_Null":
		return
	else:
		$Attack_Collision/AnimationPlayer.play("Attack_Null")
		if att_direction != "Down":
			att_direction = "Neutral"

func _on_Platform_Fall_Timer_timeout():
	platform_fall_count = 0
