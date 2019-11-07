extends KinematicBody2D

const GRAVITY = 30
const ACCELERATION = 100
const MAX_SPEED = 450
const JUMP_HEIGHT = -700

var velocity = Vector2()
var dodge_velocity = Vector2()

enum {IDLE,WALK,RUN,JUMP,FALLING,FAST_FALLING,ATTACK,STUNNED}

const EPSILON = 0.001

var max_jumps = 3
var current_jumps = 0
var platform_fall = false

var current_platform = null

var state 

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
	if Input.is_action_pressed("left_1"):
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
	elif Input.is_action_pressed("right_1"):
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	else:
		friction = true
		# This slows down our character from their current velocity to 0, 20% each frame
		velocity.x = lerp(velocity.x, 0, 0.2)
	
	if Input.is_action_just_pressed("jump_1"):
		if current_jumps < max_jumps:
			change_state(JUMP)
	
	if Input.is_action_just_pressed("down_1"):
		if state != FAST_FALLING:
			if !is_on_floor():
				if velocity.y < 0:
					velocity.y = 0
				change_state(FAST_FALLING)
		if current_platform != null:
			if current_platform.is_in_group("one_way_platform"):
				current_platform = null
				position.y += 1
	
	if Input.is_action_just_released("down_1"):
		platform_fall = false
		if !is_on_floor():
			change_state(FALLING)
		else:
			change_state(IDLE)

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			platform_fall = false
			#print("idle")
		WALK:
			pass
			#print("Walk")
		RUN:
			pass
			#print("run")
		JUMP: 
			velocity.y = JUMP_HEIGHT
			current_jumps += 1
			#print("jump")
		FALLING:
			pass
			#print("Falling")
		FAST_FALLING:
			platform_fall = true
			#print("Fast Falling")
		ATTACK:
			pass
			#print("Attack")
		STUNNED:
			pass
			#print("Stunned")

func _on_Area2D_body_entered(body):
	current_platform = body

func _on_Area2D_body_exited(body):
	current_platform = null
