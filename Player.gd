extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const JUMP_RELEASE_MODIFIER = 0.6
const ACCELERATION = 600;
const FRICTION = 1200;
const GRAVITY = 500

func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	set_horizontal_speed(input_axis, delta)	
	apply_gravity(delta)
	allow_jumping()
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	# If we just left the ledge, without jumping, start coyote time
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		coyote_jump_timer.start()
	
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func allow_jumping():
	if is_on_floor() || !coyote_jump_timer.is_stopped():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
	if !is_on_floor():
		if Input.is_action_just_released("ui_accept") && velocity.y < JUMP_VELOCITY * JUMP_RELEASE_MODIFIER:
			velocity.y *= JUMP_RELEASE_MODIFIER
				
func set_horizontal_speed(input_axis, delta):
	# Speed up
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCELERATION * delta)
	# Slow down
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if !is_on_floor():
		animated_sprite_2d.play("jump")
