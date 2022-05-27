extends Node

func in_line(p1, p2, p):
#	print(str(p1.angle_to_point(p)) + " != " + str(p1.angle_to_point(p2)))
	return ((p1.angle_to_point(p) == p1.angle_to_point(p2)) and (p1.distance_to(p) < p1.distance_to(p2)))

func angle_round(ang):
#	print("cot_angle: %s; round_ang: %s" % [angle_cot(ang), floor(angle_cot(ang)/(360/8))*45])
	return round(angle_cot(ang)/(360/8))*45

func angle_cot(ang, rad = false):
	if (rad):
		ang = rad2deg(ang)
	return ang - (floor(ang/360) * 360)

func angle_ref(ang, rad = false):
	if (rad):
		ang = rad2deg(ang)
	if (ang > 90):
		var sub = floor(ang/180)*180
		return ang - sub
	elif (ang < 0):
		if (abs(ang) > 90):
			var abs_ang = abs(ang)
			var sub = floor(abs_ang/180)*180
			return abs_ang - sub
		else:
			return abs(ang)
	else:
		return ang
