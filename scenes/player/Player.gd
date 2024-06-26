extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

# The starting_position needs to be defined with @onready
# This is because otherwise, we'd try to access the global_position
# before the node is initialized
# https://youtu.be/4nlyb2DZzUo?si=suhIvyPmAzdDT2Jp&t=1365
@onready var starting_position = global_position
@export var movement_data : PlayerMovementData
var air_jump = false

func _physics_process(delta):
	var input_axis = Input.get_axis("ui_left", "ui_right")
	set_horizontal_speed(input_axis, delta)
	apply_gravity(delta)
	allow_jumping(input_axis)
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	# If we just left the ledge, without jumping, start coyote time
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		coyote_jump_timer.start()
	
	if Input.is_key_pressed(KEY_ESCAPE):
		movement_data = load("res://custom_resources/player_movement_data/FastMovementData.tres")
	
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += movement_data.gravity * movement_data.gravity_scale * delta

func allow_jumping(input_axis):
	var just_wall_jumped = allow_wall_jumping(input_axis)
	if is_on_floor() || just_wall_jumped:
		air_jump = true
	
	# Normal jump
	if is_on_floor() || !coyote_jump_timer.is_stopped():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
	
	# Double jump (only activates after coyote time has stopped)
	if !is_on_floor() && coyote_jump_timer.is_stopped() && !just_wall_jumped:
		if Input.is_action_just_pressed("ui_accept") and air_jump:
				velocity.y = movement_data.jump_velocity * 0.7
				air_jump = false
	
	# Decrease jump height on key release
	if !is_on_floor():
		if Input.is_action_just_released("ui_accept") && velocity.y < movement_data.jump_velocity * movement_data.jump_release_modifier:
			velocity.y *= movement_data.jump_release_modifier

func allow_wall_jumping(input_axis : float) -> bool:
	var just_jumped = false
	if !is_on_wall_only(): return just_jumped
	
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_accept"):
		if wall_normal == Vector2.LEFT:
			velocity.x = wall_normal.x * movement_data.speed
			velocity.y = movement_data.jump_velocity
			just_jumped = true
		if wall_normal == Vector2.RIGHT:
			velocity.x = wall_normal.x * movement_data.speed
			velocity.y = movement_data.jump_velocity
			just_jumped = true
			
	return just_jumped
	
#region Horizontal movement
func set_horizontal_speed(input_axis, delta):
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	handle_friction(input_axis, delta)

func apply_air_resistance(input_axis, delta):
	if !is_on_floor() && input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_acceleration(input_axis, delta):
	if is_on_floor() && input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if !is_on_floor() && input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.air_acceleration * delta)

func handle_friction(input_axis, delta):
	if input_axis == 0 && is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
#endregion

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if !is_on_floor():
		animated_sprite_2d.play("jump")

func _on_hazard_detector_area_entered(area):
	global_position = starting_position
