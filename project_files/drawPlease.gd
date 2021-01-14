extends Node2D
var mesh 
var rat =10
func _ready():
	mesh = get_node("../MeshInstance")
	
	set_process(true)
	pass

func _process(delta):
	if  Input.is_action_just_pressed("fire"):
		mesh.lines.clear()
		mesh.triangles.clear()

		mesh.verteks.append(get_global_mouse_position()/rat)
		mesh.findTriangles(mesh.verteks)
		mesh.Make_Mesh(mesh.triangles,-1)
	if  Input.is_action_just_pressed("ui_right"):
		mesh.selected = (mesh.selected + 1) % mesh.lines.size()
	if  Input.is_action_just_pressed("ui_left"):
		mesh.selected = (mesh.selected -1) % mesh.lines.size()
	
	update()
	pass


func _draw():
	if mesh.lines.size() >=2:
		for i in range(0,mesh.lines.size(),2):
			var B = (i + 1) % mesh.lines.size()
			draw_line(mesh.lines[i]*rat, mesh.lines[B]*rat, Color(0, 0, 255), 1)
	
	for i in mesh.verteks.size():
		var B = (i + 1) % mesh.verteks.size()
		draw_line(mesh.verteks[i]*rat, mesh.verteks[B]*rat, Color(255, 0, 0), 1)
		
	
	
	draw_circle(mesh.verteks[0]*rat,4,Color(100,100,0))
	draw_circle(mesh.verteks[mesh.verteks.size()-1]*rat,4,Color(244,66,0))
	
	draw_circle(mesh.lines[mesh.selected]*rat,4,Color.gray)