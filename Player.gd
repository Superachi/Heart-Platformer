extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

@export var movement_data : PlayerMovementData

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
	
	if Input.is_key_pressed(KEY_ESCAPE):
		movement_data = load("res://SlowMovementData.tres")
	
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += movement_data.gravity * movement_data.gravity_scale * delta

func allow_jumping():
	if is_on_floor() || !coyote_jump_timer.is_stopped():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
	if !is_on_floor():
		if Input.is_action_just_released("ui_accept") && velocity.y < movement_data.jump_velocity * movement_data.jump_release_modifier:
			velocity.y *= movement_data.jump_release_modifier
				
func set_horizontal_speed(input_axis, delta):
	# Speed up
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)
	# Slow down
	else:
		velocity.x = move_toward(velocity.x, 0, movement_data.acceleration * delta)
		
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if !is_on_floor():
		animated_sprite_2d.play("jump")
