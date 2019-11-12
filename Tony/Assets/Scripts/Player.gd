extends KinematicBody2D

const GRAVITY = 35
const ACCELERATION = 100
const MAX_SPEED = 450
const JUMP_HEIGHT = -700

var debug_mode = false

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
	var friction = false
	if Input.is_action_just_pressed("debug_mode"):
		debug_mode = !debug_mode
		print("debug_mode: ", debug_mode)
	if Input.is_action_pressed("left_%s" % player_number):
		att_direction = "Left"
		facing_dir = "Left"
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	elif Input.is_action_pressed("right_%s" % player_number):
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
	
	if Input.is_action_just_pressed("jump_%s" % player_number):
		if current_jumps < max_jumps:
			change_state(JUMP)
	
	if Input.is_action_pressed("down_%s" % player_number):
		if state == JUMP or state == FALLING or state == FAST_FALLING:
			att_direction = "Down"
		if state != FAST_FALLING:
			if !is_on_floor():
				if velocity.y < 0:
					velocity.y = 0
				change_state(FAST_FALLING)
		att_direction = "Down"
	
	if Input.is_action_just_pressed("down_%s" % player_number):
		platform_fall_count += 1
		$Platform_Fall_Timer.start()
		if current_platform != null and platform_fall_count >= 2:
			if current_platform.is_in_group("one_way_platform"):
				current_platform = null
				position.y += 1
	
	if Input.is_action_just_released("down_%s" % player_number):
		platform_fall = false
		if !is_on_floor():
			change_state(FALLING)
		else:
			change_state(IDLE)
	
	if Input.is_action_pressed("up_%s" % player_number):
		att_direction = "Neutral"
	
	if Input.is_action_just_pressed("attack_%s" % player_number):
		change_state(ATTACK)

#var current_speed = velocity.x 
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			platform_fall = false
			att_direction = "Neutral"
			$Attack_Collision/AnimationPlayer.play("Attack_Null")
			if debug_mode:
				print("idle")
		WALK:
			if debug_mode:
				print("Walk")
		RUN:
			if debug_mode:
				print("run")
		JUMP: 
			velocity.y = JUMP_HEIGHT
			current_jumps += 1
			att_direction = "Neutral"
			if debug_mode:
				print("jump")
		FALLING:
			if velocity.x > EPSILON:
				att_direction = "Right"
			elif velocity.x < EPSILON:
				att_direction = "Left"
			else:
				att_direction = "Down"
			if debug_mode:
				print("Falling")
		FAST_FALLING:
			if platform_fall_count >= 2:
				platform_fall = true
			att_direction = "Down"
			if debug_mode:
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
			if att_direction == "Left":
				$Attack_Collision/AnimationPlayer.play("Attack_Left")
			if att_direction == "Right":
				$Attack_Collision/AnimationPlayer.play("Attack_Right")
#			yield(get_tree().create_timer(1.5), "timeout")
#			velocity.x = current_speed
			#print("Attack")
		STUNNED:
			att_direction = "Neutral"
			#print("Stunned")

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
