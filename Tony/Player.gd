extends KinematicBody

export (int) var speed
export (int) var jump_speed

var velocity = Vector3()
var gravity = 0.5

const EPSILON = 0.001

var can_jump = true

func _ready():
	pass

func _process(delta):
	print(can_jump)
	if velocity.y <= EPSILON:
		can_jump = true
	get_input()

func _physics_process(delta):
	velocity.y -= gravity
	
	velocity = move_and_slide(velocity * speed, Vector3.UP)

func get_input():
	velocity = Vector3()
	
	if Input.is_action_pressed("left_1"):
		velocity.x = -1
	if Input.is_action_pressed("right_1"):
		velocity.x = 1
	if Input.is_action_just_pressed("jump_1"):
		if velocity.y < EPSILON:
			velocity.y = 10
			can_jump = false
	if Input.is_action_pressed("dodge_1"):
		pass
