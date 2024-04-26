extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const ACCELERATION = 600;
const FRICTION = 1200;
const GRAVITY = 500

func _physics_process(delta):
	set_horizontal_speed(delta)	
	apply_gravity(delta)
	allow_jumping()
	move_and_slide()
	
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func allow_jumping():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
		else:
			if Input.is_action_just_released("ui_accept") && velocity.y < JUMP_VELOCITY / 2:
				velocity.y /= 2
				
func set_horizontal_speed(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	# Speed up
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCELERATION * delta)
	# Slow down
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
