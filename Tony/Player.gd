extends KinematicBody

export (int) var speed
export (int) var jump_speed

var velocity = Vector3()
var gravity = 4

const EPSILON = 0.001

var can_jump = true
var max_jumps = 3
var current_jumps = 0
var slow_fall = false
var platform_fall = false

var current_platform = null

func _ready():
	pass

func _process(delta):
	# When we are at 0 velocity
	# BASICALLY WHEN WE TOUCH THE GROUND
	if velocity.y < EPSILON and velocity.y >= 0:
		can_jump = true
		current_jumps = 0
	get_input()

func _physics_process(delta):
	if slow_fall:
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
		else:
			can_jump = false
	
	if Input.is_action_pressed("down_1"):
		if not slow_fall:
			velocity.y = -20
		slow_fall = true
		if current_platform != null:
			current_platform.get_node("StaticBody/CollisionShape").disabled = true
	
	if Input.is_action_just_released("down_1"):
		platform_fall = false
		slow_fall = false
	
	if Input.is_action_just_pressed("dodge_1"):
		if Input.is_action_pressed("left_1"):
			velocity.x = -4
		elif Input.is_action_pressed("right_1"):
			velocity.x = 4
		else:
			#dodge code goes here
			pass


func _on_Area_area_entered(area):
	if area.is_in_group("one_way_platform"):
		current_platform = area

func _on_Area_area_exited(area):
	if area.is_in_group("one_way_platform"):
		current_platform = null
