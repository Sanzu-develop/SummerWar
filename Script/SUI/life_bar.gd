class_name LifeBar
extends Sprite2D


@export var soldier: Soldier
@export var tower: Tower
@export var height: int = 2



func _ready() -> void:
	create_texture()
	atualize_image()

func create_texture():
	var image = Image.create(10,height,false,Image.FORMAT_RGB8)
	image.fill(Color.DARK_RED)
	
	texture = ImageTexture.create_from_image(image)

func atualize_image():
	if not soldier and not tower: return
	
	if not texture: create_texture()
	
	var image = texture.get_image()
	
	if soldier:
		var max_life = soldier.atributes_resource.get_max_life()
		var size_image = Vector2i(max_life,height)
		
		if size_image != image.get_size():
			image.resize(max_life,height,Image.INTERPOLATE_NEAREST)
		
		var life = soldier.atributes_resource.get_life()
		var rect_life = Rect2i(0,0,life,height)
		
		var background_color = soldier.atributes_resource.background_color
		var life_color = soldier.atributes_resource.life_color
		
		image.fill(background_color)
		image.fill_rect(rect_life,life_color)
		
		texture = ImageTexture.create_from_image(image)
	
	elif tower:
		var max_life = tower.get_max_life()
		var size_image = Vector2i(max_life,height)
		
		if size_image != image.get_size():
			image.resize(max_life,height,Image.INTERPOLATE_NEAREST)
		
		var life = tower.get_life()
		var rect_life = Rect2i(0,0,life,height)
		
		var background_color = tower.color_background
		var life_color = tower.color_life
		
		image.fill(background_color)
		image.fill_rect(rect_life,life_color)
		
		texture = ImageTexture.create_from_image(image)
