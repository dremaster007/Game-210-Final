extends KinematicBody

export (int) var speed
export (int) var jump_speed

var velocity = Vector3()
var dodge_velocity = Vector3()
var gravity = 4

const EPSILON = 0.001

var dodging = false
var on_ground = true
var can_jump = true
var max_jumps = 3
var current_jumps = 0
var fast_fall = false
var platform_fall = false

var current_platform = null

func _ready():
	pass

func _process(delta):
	# When we are at 0 velocity
	# BASICALLY WHEN WE TOUCH THE GROUND
	if velocity.y < EPSILON and velocity.y >= -EPSILON:
		can_jump = true
		on_ground = true
		current_jumps = 0
	elif velocity.y > EPSILON or velocity.y < -EPSILON:
		on_ground = false
	get_input()

func _physics_process(delta):
	if dodging:
		velocity = dodge_velocity
	if not dodging:
		if fast_fall:
			velocity.y -= gravity * 1.25
			velocity.y = max(velocity.y, -75)
		else:
			velocity.y -= gravity
			velocity.y = max(velocity.y, -50)
	
	
	velocity = move_and_slide(Vector3(velocity.x * speed, velocity.y, 0), Vector3.UP)

func get_input():
	velocity.x = 0
	velocity.z = 0
	
	if Input.is_action_pressed("left_1"):
		velocity.x += -1
	
	if Input.is_action_pressed("right_1"):
		velocity.x += 1
	
	if Input.is_action_just_pressed("jump_1") and can_jump:
		if current_jumps < max_jumps:
			velocity.y = jump_speed
			current_jumps += 1
	
	if Input.is_action_pressed("down_1"):
		if not fast_fall:
			velocity.y = -20
			fast_fall = true
		if current_platform != null:
			current_platform.get_node("StaticBody/CollisionShape").disabled = true
	
	if Input.is_action_just_released("down_1"):
		platform_fall = false
		fast_fall = false
	
	if Input.is_action_just_pressed("dodge_1"):
		if Input.is_action_pressed("left_1") and on_ground:
			velocity.x = -8
		elif Input.is_action_pressed("right_1") and on_ground:
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
	dodging = true
	set_collision_mask_bit(2, false)
	$MeshInstance.hide()
	match dir:
		"left":
			dodge_velocity = Vector3(-1, 0, 0)
		"right":
			dodge_velocity = Vector3(1, 0, 0)
		"up":
			dodge_velocity = Vector3(0, 24, 0)
		"down":
			dodge_velocity = Vector3(0, -24, 0)
		"up_left":
			dodge_velocity = Vector3(-1, 24, 0)
		"down_left":
			dodge_velocity = Vector3(-1, -24, 0)
		"up_right":
			dodge_velocity = Vector3(1, 24, 0)
		"down_right":
			dodge_velocity = Vector3(1, -24, 0)
		"neutral":
			dodge_velocity = Vector3(0, 0, 0)
	
	yield(get_tree().create_timer(0.5),"timeout")
	dodging = false
	set_collision_mask_bit(2, false)
	$MeshInstance.show()

func _on_Area_area_entered(area):
	if area.is_in_group("one_way_platform"):
		current_platform = area

func _on_Area_area_exited(area):
	if area.is_in_group("one_way_platform"):
		current_platform = null
