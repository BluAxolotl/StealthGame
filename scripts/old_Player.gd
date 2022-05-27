extends KinematicBody2D

var UP = Vector2(0,-1)
const SPEED = 700
const ACCEL = 300
const GRAV = 80
const JUMP = -1500

const MAX_VELO = Vector2(1500, 1500)

var motion = Vector2(0,0)
var l_forces = Vector2(0,0)
var g_forces = Vector2(0,0)
var wall = false
var floories = false
var joy_dir = 0
var spr_dir = 1
var last_joy_dir = 0
var ground_timer = 0
var free_timer = 0
var jump_buffer = false
var can_jump = true
var old_pos = Vector2(0,0)

func _process(delta):
	if (Input.is_action_just_pressed("L")):
		joy_dir = -1
		spr_dir = -1
	if (Input.is_action_just_pressed("R")):
		joy_dir = 1
		spr_dir = 1
	
	if (Input.is_action_just_released("L") || Input.is_action_just_released("R")):
		if (Input.is_action_pressed("L")):
			joy_dir = -1
			spr_dir = -1
		elif (Input.is_action_pressed("R")):
			joy_dir = 1
			spr_dir = 1
		else:
			joy_dir = 0
	
	if (joy_dir == 0):
		motion.x /= 1.2
	
	if (Input.is_action_just_pressed("A") and can_jump):
#		print("JUMPING")
#		print(sin(deg2rad(rotation_degrees+90))*JUMP)
		l_forces.x = cos(deg2rad(rotation_degrees+90))*JUMP
		l_forces.y = sin(deg2rad(rotation_degrees+90))*JUMP
		jump_buffer = true
		can_jump = false
	
	if (free_timer > 5):
		$AnimPlayer.play("Jump")
#		print(motion.y)
		if (motion.y < -100):
			$Sprite.frame = 0
		elif motion.y < 0:
			$Sprite.frame = 1
		else:
			$Sprite.frame = 2
	else:
		if (joy_dir == 1 or joy_dir == -1):
			$AnimPlayer.play("Run")
		else:
			$AnimPlayer.play("Idle")
	
	$Sprite.flip_h = (spr_dir == -1)
	
	last_joy_dir = joy_dir
	old_pos = position

func _physics_process(delta):
	var collision = null
	if (get_slide_count() != 0):
		collision = get_slide_collision(get_slide_count()-1)
	floories = (collision != null)
	print($RayCast2D.is_colliding())
	if ($RayCast2D.is_colliding()):
		free_timer = 0
		ground_timer += 1
		if (ground_timer == 1):
#			print("GROUNDED")
			motion.y = 0
			can_jump = true
	else:
		free_timer += 1
		if (free_timer == 1):
#			print("FREE")
			ground_timer = 0
			jump_buffer = false
		motion.y += GRAV
	
	if (joy_dir != 0):
		if ((joy_dir == 1 and motion.x < SPEED) or (joy_dir == -1 and motion.x > -SPEED)):
			motion.x += ACCEL*joy_dir
		else:
			motion.x = SPEED*joy_dir
	
	motion += l_forces
	l_forces = Vector2(0,0)
	motion += g_forces.rotated(deg2rad(rotation_degrees))
	g_forces = Vector2(0,0)
	
	motion.x = clamp(motion.x, -MAX_VELO.x, MAX_VELO.x)
	motion.y = clamp(motion.y, -MAX_VELO.y, MAX_VELO.y)
	
#	print(motion)
	
	var motion_final = motion.rotated(deg2rad(rotation_degrees))
	move_and_slide(motion_final, UP)
	if (collision != null):
		var pos = collision.position
		var i = 0
		if ((abs(UP.x - collision.normal.x) > 0.05 or abs(UP.y - collision.normal.y) > 0.05)):
#			print("SNAPPING")
			can_jump = true
			var ang = round(rad2deg(Vector2(0,0).angle_to_point(collision.normal)))-90
			
			if (rotation_degrees != ang):
				rotation_degrees = ang
			UP = collision.normal
	else:
		rotation_degrees = 0
		UP = Vector2(0,-1)

func _ready():
	pass
