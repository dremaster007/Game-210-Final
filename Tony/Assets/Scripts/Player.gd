extends KinematicBody2D

export (int) var speed
export (int) var jump_speed

var velocity = Vector2()
var dodge_velocity = Vector2()
var gravity = 20

enum {IDLE,WALK,RUN,JUMP,FALLING,FAST_FALLING,ATTACK,STUNNED,DODGING}

const EPSILON = 0.001

var can_jump = true
var max_jumps = 3
var current_jumps = 0
var platform_fall = false

var current_platform = null

var state 

func _ready():
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
			velocity.y = -jump_speed
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
		DODGING:
			velocity = dodge_velocity
			set_collision_mask_bit(2, false)
			$Sprite2D.hide()
			#print("dodge")
			yield(get_tree().create_timer(0.5),"timeout")
			set_collision_mask_bit(2, false)
			$Sprite2D.show()
			change_state(IDLE)

func _process(delta):
	# When we are at 0 velocity
	# BASICALLY WHEN WE TOUCH THE GROUND
#	if velocity.y < EPSILON and velocity.y >= -EPSILON:
#		can_jump = true
#		on_ground = true
#		current_jumps = 0
#		change_state(IDLE)
#	elif velocity.y > EPSILON or velocity.y < -EPSILON:
#		on_ground = false
	if is_on_floor():
		change_state(IDLE)
		can_jump = true
		current_jumps = 0
	elif state == JUMP and velocity.y > EPSILON:
		change_state(FALLING)
	get_input()

func _physics_process(delta):
	if state == DODGING:
		velocity = dodge_velocity
	if state != DODGING:
		print(velocity.y)
		if state == FAST_FALLING:
			velocity.y += gravity * 1.5
			velocity.y = min(velocity.y, 750)
		else:
			velocity.y += gravity
			velocity.y = min(velocity.y, 500)
	
	
	velocity = move_and_slide(Vector2(velocity.x * speed, velocity.y), Vector2.UP)

func get_input():
	velocity.x = 0
	
	if Input.is_action_pressed("left_1") and state != DODGING:
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = -1
	
	if Input.is_action_pressed("right_1") and state != DODGING:
		if is_on_floor():
			if state != WALK:
				change_state(WALK)
		velocity.x = 1
	
	if Input.is_action_just_pressed("jump_1") and can_jump:
		if current_jumps < max_jumps:
			change_state(JUMP)
	
	if Input.is_action_pressed("down_1"):
		if state != FAST_FALLING:
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
	
	if Input.is_action_just_pressed("dodge_1"):
		if Input.is_action_pressed("left_1") and is_on_floor():
			change_state(DODGING)
			velocity.x = -8
		elif Input.is_action_pressed("right_1") and is_on_floor():
			change_state(DODGING)
			velocity.x = 8
		else:
			check_dir()
			

func check_dir():
	var dir = ""
	
	var left = Input.is_action_pressed("left_1")
	var right = Input.is_action_pressed("right_1")
	var up = Input.is_action_pressed("up_1")
	var down = Input.is_action_pressed("down_1")
	
	if left:
		if up:
			dir = "up_left"
		elif down:
			dir = "down_left"
		else:
			dir = "left"
	
	elif right:
		if up:
			dir = "up_right"
		elif down:
			dir = "down_right"
		else:
			dir = "right"
	
	elif up:
		dir = "up"
	
	elif down:
		dir = "down"
	
	else:
		dir = "neutral"
	
	dodge(dir)

func dodge(dir):
	change_state(DODGING)
	match dir:
		"left":
			dodge_velocity = Vector2(-1, 0)
		"right":
			dodge_velocity = Vector2(1, 0)
		"up":
			dodge_velocity = Vector2(0, 24)
		"down":
			dodge_velocity = Vector2(0, -24)
		"up_left":
			dodge_velocity = Vector2(-1, 24)
		"down_left":
			dodge_velocity = Vector2(-1, -24)
		"up_right":
			dodge_velocity = Vector2(1, 24)
		"down_right":
			dodge_velocity = Vector2(1, -24)
		"neutral":
			dodge_velocity = Vector2(0, 0)

func _on_Area2D_body_entered(body):
	current_platform = body

func _on_Area2D_body_exited(body):
	current_platform = null
