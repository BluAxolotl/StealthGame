extends Camera2D

var target = null

func _process(_delta):
	if (target):
		position.x = target.position.x
		position.y = target.position.y
#		var target_rot = target.rotation_degrees
##		var loop = 0
##		if (rotation_degrees < 0 and target_rot > 0):
##			loop = 1
##			rotation_degrees = 360-rotation_degrees
##		elif (rotation_degrees > 0 and target_rot < 0):
##			loop = -1
##			target_rot = 360-target_rot
#		var am = abs(target_rot - rotation_degrees)
#		var speed = 5
#		if (am > 1):
##			print("rot: %s; target_rot: %s" % [rotation_degrees, target_rot])
#			if (rotation_degrees > target_rot):
#				rotation_degrees -= am/speed
#			elif (rotation_degrees < target_rot):
#				rotation_degrees += am/speed
#		else:
#			rotation_degrees = target_rot
