extends KinematicBody2D

var UP = Vector2(0,-1)
var GRAV = 200
const SPEED = 700
const ACCEL = 300
const JUMP = -1500
const MAX_VELO = Vector2(1500, 1500)
const TILEANGLE = {
	1: 0,
	16: 45,
	5: 90,
	17: 135,
	7: 180,
	13: 225,
	3: 270,
	12: 315,
}

var motion = Vector2(0,0)
var add_motion = Vector2(0,0)
var moving = false
var grab_mode = false
var touch_wall = false
var free = false
var joy_dir = 0
var spr_dir = 1
var last_joy_dir = 0
var ground_timer = 0
var free_timer = 0
var bump_timer = 0
var can_jump = true
var jump_buffer = 0
var stage = null

func _ready():
	stage = get_parent().get_node("Stage")

func _process(_delta):
	touch_wall = $Area.get_overlapping_bodies().has(stage)
	
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
		var manu_ang = Vector2(0,0).angle_to_point(Vector2(motion.x, -JUMP))
		add_motion.x = cos(deg2rad(rotation_degrees+90))*JUMP
		add_motion.y = sin(deg2rad(rotation_degrees+90))*JUMP
		print(add_motion)
		jump_buffer = 10
		can_jump = false
	
	if (Input.is_action_pressed("HOLD") and touch_wall and jump_buffer == 0):
		grab_mode = true
		GRAV = 10000
	else:
		GRAV = 50
		grab_mode = false
	
	if (Input.is_action_just_released("HOLD")):
		rotation_degrees = 0
		UP = Vector2(0,-1)
	
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
		can_jump = true
		if (joy_dir == 1 or joy_dir == -1):
			$AnimPlayer.play("Run")
		else:
			$AnimPlayer.play("Idle")
	
	$Sprite.flip_h = (spr_dir == -1)
	
	last_joy_dir = joy_dir
	jump_buffer -= (1 if jump_buffer > 0 else 0 )

func _physics_process(_delta):
	var div = (1 if Input.is_action_pressed("B") else 2)
	if (joy_dir != 0):
		if ((joy_dir == 1 and motion.x < (SPEED/div)) or (joy_dir == -1 and motion.x > (-SPEED/div))):
			motion.x += (ACCEL*joy_dir)/div
		else:
			motion.x = (SPEED*joy_dir)/div

	if (is_on_floor()):
		free_timer = 0
		ground_timer += 1
		if (ground_timer == 1):
			add_motion.y = 0
		can_jump = true
		motion.y = 0
	else:
		ground_timer = 0
		free_timer += 1
		motion.y += GRAV
	
	if (is_on_ceiling()):
		bump_timer += 1
		if (bump_timer == 1):
			motion.y = 0
			add_motion.y = 0
	else:
		bump_timer = 0
	
	motion.x = clamp(motion.x, -MAX_VELO.x, MAX_VELO.x)
	motion.y = clamp(motion.y, -MAX_VELO.y, MAX_VELO.y)

#	print($Area.get_overlapping_bodies())
	var rot = rotation_degrees
	var rad_rot = deg2rad(rot-90)
	
	var collision = null
	if (get_slide_count() != 0):
		collision = get_slide_collision(get_slide_count()-1)
	if (collision != null):
		var coords = ((collision.position-(collision.normal*20))/80).floor()
		var idx = stage.get_cellv(coords)
#		print("%s: %s" % [coords, idx])
		var right_side_up = [0, 45, 315]
		if (TILEANGLE.has(idx)):
			if (right_side_up.has(TILEANGLE[idx])):
				rot = TILEANGLE[idx]
				rad_rot = deg2rad(TILEANGLE[idx]-90)
				rotation_degrees = rot
				UP = Vector2(cos(rad_rot),sin(rad_rot))
			elif (grab_mode):
				rot = TILEANGLE[idx]
				rad_rot = deg2rad(TILEANGLE[idx]-90)
				rotation_degrees = rot
				UP = Vector2(cos(rad_rot),sin(rad_rot))
			elif (free_timer > 0):
				rotation_degrees = 0
				UP = Vector2(0,-1)
#		print("idx: %s; %s" % [idx, Vector2(2,0).rotated(deg2rad(rot))])
	elif (!touch_wall):
		rotation_degrees = 0
		UP = Vector2(0,-1)
#		print("(elif) %s" % Vector2(2,0).rotated(deg2rad(rot)))
	var motion_final = motion.rotated(rad_rot+deg2rad(90))
	var _bitch = move_and_slide(motion_final+add_motion, UP)
	add_motion /= 1.05
