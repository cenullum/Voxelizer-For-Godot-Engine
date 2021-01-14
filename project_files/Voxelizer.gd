extends MeshInstance

#made by cenullum 

var surfTool = SurfaceTool.new()
var triangleCount =0

export(float)var turning_speed=0.5
export(float)var move_speed=10
export (int) var depth=1
export(float,0.1,1.0)var alpha_offset=1.0

export(Texture) var voxel_me
export (Material) var material #this have to be transparent and its depth draw mode must be opaque pre-pass

var height:float
var width:float
var img 


var debug=false


func _ready():
	get_tree().connect("files_dropped", self, "_files_dropped")
	if is_instance_valid(voxel_me):
		voxelization(voxel_me)


export(Vector2) var icon_size = Vector2(64, 64)

func _files_dropped(images, screen):
	$ItemList.clear()
	var extensions = ResourceLoader.get_recognized_extensions_for_type("Texture")
	
	var im = Image.new()
	var err = im.load(images[0])
	if err != OK:
		print("Could not load image file")
		return
	
	var tex = ImageTexture.new()
	tex.create_from_image(im, Texture.FLAGS_DEFAULT)
	voxelization(tex)
	$ItemList.add_item(images[0], tex, true)






func _process(delta):
	
	if Input.is_action_pressed("rotate_up"):
		rotate(Vector3.LEFT,turning_speed*delta)
	if Input.is_action_pressed("rotate_down"):
		rotate(Vector3.RIGHT,turning_speed*delta)
	if Input.is_action_pressed("rotate_left"):
		rotate(Vector3.DOWN,turning_speed*delta)
	if Input.is_action_pressed("rotate_right"):
		rotate(Vector3.UP,turning_speed*delta)
	if Input.is_action_pressed("move_up"):
		translate(get_global_transform().basis.z.normalized() * delta*-move_speed)
	if Input.is_action_pressed("move_down"):
		translate(get_global_transform().basis.z.normalized() * delta*move_speed)

func voxelization(spr):
	var ms = OS.get_ticks_msec()
	triangleCount=0
	voxel_me=spr
	if spr == null:
		return
	img = spr.get_data()
	img.lock()
	height = spr.get_height()
	width = spr.get_width()
	var mesh = Mesh.new()
	surfTool.set_material(material)
	material.albedo_texture = spr
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in spr.get_width():
		for y in spr.get_height():
			var _color = img.get_pixel ( x,y ) 
			if _color.a >=alpha_offset: # get all opaque pixels send check for sides
				make_cube(Vector2(x,y))
			else:
				img.set_pixel(x,y,Color.transparent)#if it is under the offset pixel will be transparent
	
	make_up_down_side()
	surfTool.generate_normals(false)
	surfTool.index()
	surfTool.commit(mesh)
	self.set_mesh(mesh)
	self.set_surface_material(0,material)
	
	if(debug):
		var itex = ImageTexture.new()
		itex.create_from_image(img,0)
		material.albedo_texture = itex
	
	img.unlock()
	ms -= OS.get_ticks_msec()
	

	get_node("information").text="voxelization is done in "+str(abs(ms))+" ms"+"\nthere are "+str(triangleCount)+ " triangle"



func make_up_down_side():
	#   -Vector3(width/2,height/2,0) and -Vector3(width/2,height/2,-depth) is for correcting offset
	
	### front side
	# y is 1 or height+1 because of fixing gliding upwards
	var vec1 = Vector3(width,height+1,0)-Vector3(width/2,height/2,-depth)
	var vec2 = Vector3(width,1,0)-Vector3(width/2,height/2,-depth)
	var vec3 = Vector3(0,1,0)-Vector3(width/2,height/2,-depth)
	
	surfTool.add_uv(Vector2(1.0,0.0))
	surfTool.add_vertex(vec1)
	surfTool.add_uv(Vector2(1.0,1.0))
	surfTool.add_vertex(vec2)
	surfTool.add_uv(Vector2(0.0,1.0))
	surfTool.add_vertex(vec3)
	triangleCount+=1
  #other triangle
	vec1 = Vector3(0,1,0)-Vector3(width/2,height/2,-depth)
	vec2 = Vector3(0,height+1,0)-Vector3(width/2,height/2,-depth)
	vec3 = Vector3(width,height+1,0)-Vector3(width/2,height/2,-depth)

	surfTool.add_uv(Vector2(0.0,1.0))
	surfTool.add_vertex(vec1)
	surfTool.add_uv(Vector2(0.0,0.0))
	surfTool.add_vertex(vec2)
	surfTool.add_uv(Vector2(1.0,0.0))
	surfTool.add_vertex(vec3)
	triangleCount+=1
	
	### back side
	vec1 = Vector3(0,height+1,0)-Vector3(width/2,height/2,0)
	vec2 = Vector3(0,1,0)-Vector3(width/2,height/2,0)
	vec3 = Vector3(width,1,0)-Vector3(width/2,height/2,0)
	
	surfTool.add_uv(Vector2(0.0,0.0))
	surfTool.add_vertex(vec1)
	surfTool.add_uv(Vector2(0.0,1.0))
	surfTool.add_vertex(vec2)
	surfTool.add_uv(Vector2(1.0,1.0))
	surfTool.add_vertex(vec3)
	triangleCount+=1
  #other triangle
	vec1 = Vector3(width,1,0)-Vector3(width/2,height/2,0)
	vec2 = Vector3(width,height+1,0)-Vector3(width/2,height/2,0)
	vec3 = Vector3(0,height+1,0)-Vector3(width/2,height/2,0)
	
	surfTool.add_uv(Vector2(1.0,1.0))
	surfTool.add_vertex(vec1)
	surfTool.add_uv(Vector2(1.0,0.0))
	surfTool.add_vertex(vec2)
	surfTool.add_uv(Vector2(0.0,0.0))
	surfTool.add_vertex(vec3)
	triangleCount+=1
	

func make_cube(pixel_pos):# this works on each pixels in the loop that above
	#-Vector3(width/2,height/2,0) is for correcting offset
	
		if pixel_pos.x==0 or  img.get_pixel (pixel_pos.x-1,pixel_pos.y).a <alpha_offset :# is it end of image or is leftside of pixel transparent?
			
			#height-pixel_pos.y because of flipping. Without it, mesh have wrong rotation
			var vec1 = Vector3(pixel_pos.x,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			var vec2 = Vector3(pixel_pos.x,height-pixel_pos.y+1,0)-Vector3(width/2,height/2,0)
			var vec3 = Vector3(pixel_pos.x,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			
			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1
		  #other triangle
			vec1 = Vector3(pixel_pos.x,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			vec2 = Vector3(pixel_pos.x,height-pixel_pos.y,depth)-Vector3(width/2,height/2,0)
			vec3 = Vector3(pixel_pos.x,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			
			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1

		if pixel_pos.x==width-1 or img.get_pixel (pixel_pos.x+1,pixel_pos.y).a <alpha_offset :# is it end of image or is right side of pixel transparent?
			
			#height-pixel_pos.y because of flipping. Without it, mesh have wrong rotation
			var vec1 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,0)-Vector3(width/2,height/2,0)
			var vec2 = Vector3(pixel_pos.x+1,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			var vec3 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			
			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1
		  #other triangle
			vec1 = Vector3(pixel_pos.x+1,height-pixel_pos.y,depth)-Vector3(width/2,height/2,0)
			vec2 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			vec3 = Vector3(pixel_pos.x+1,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			
			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1

		if pixel_pos.y==0 or img.get_pixel (pixel_pos.x,pixel_pos.y-1).a <alpha_offset :# is it end of image or is up side of pixel transparent?

			#height-pixel_pos.y+1 because of flipping. Without it, mesh have wrong rotation and 1 pixel down
			var vec1 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,0)-Vector3(width/2,height/2,0)
			var vec2 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			var vec3 = Vector3(pixel_pos.x,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)

			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1
		  #other triangle
			vec1 = Vector3(pixel_pos.x,height-pixel_pos.y+1,depth)-Vector3(width/2,height/2,0)
			vec2 = Vector3(pixel_pos.x,height-pixel_pos.y+1,0)-Vector3(width/2,height/2,0)
			vec3 = Vector3(pixel_pos.x+1,height-pixel_pos.y+1,0)-Vector3(width/2,height/2,0)

			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1

		if pixel_pos.y==height-1 or img.get_pixel (pixel_pos.x,pixel_pos.y+1).a <alpha_offset :# is it end of image or is down side of pixel transparent?

			#height-pixel_pos.y+1 because of flipping. Without it, mesh have wrong rotation and 1 pixel down
			var vec1 = Vector3(pixel_pos.x,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			var vec2 = Vector3(pixel_pos.x,height-pixel_pos.y,depth)-Vector3(width/2,height/2,0)
			var vec3 = Vector3(pixel_pos.x+1,height-pixel_pos.y,depth)-Vector3(width/2,height/2,0)

			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1
		  #other triangle
			vec1 = Vector3(pixel_pos.x+1,height-pixel_pos.y,depth)-Vector3(width/2,height/2,0)
			vec2 = Vector3(pixel_pos.x+1,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)
			vec3 = Vector3(pixel_pos.x,height-pixel_pos.y,0)-Vector3(width/2,height/2,0)

			#adding 0.5 because there is flitchering without it on image with power of 2 scales
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec1)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec2)
			surfTool.add_uv(Vector2((pixel_pos.x+0.5)/width,(pixel_pos.y+0.5)/height))
			surfTool.add_vertex(vec3)
			triangleCount+=1



func _on_LineEdit_text_changed(new_text):
	depth = float(new_text)
	voxelization(voxel_me)
