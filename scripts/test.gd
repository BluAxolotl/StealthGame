extends Node2D

onready var stage = $Stage

func _ready():
	$Camera.target = $Player
	for ground in stage.get_children():
		var body = StaticBody2D.new()
		var collision = CollisionPolygon2D.new()
		body.name = "Body"
		collision.name = "Collision"
		collision.polygon = ground.polygon
		for point in ground.polygon:
			var visual = Sprite.new()
			var image = Image.new()
			var texture = ImageTexture.new()
			image.load("res://sprites/ind.png")
			texture.create_from_image(image)
			visual.texture = texture
			add_child(visual)
			visual.position = point + ground.position
		body.add_child(collision)
		ground.add_child(body)
