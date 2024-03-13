extends Minigame

var vertices =[
	Vector3(1,1,1),
	Vector3(1,1,-1),
	Vector3(1,-1,1),
	Vector3(1,-1,-1),
	Vector3(-1,1,1),
	Vector3(-1,1,-1),
	Vector3(-1,-1,1),
	Vector3(-1,-1,-1)
]
var target =[
	Vector3(1,1,1),
	Vector3(1,1,-1),
	Vector3(1,-1,1),
	Vector3(1,-1,-1),
	Vector3(-1,1,1),
	Vector3(-1,1,-1),
	Vector3(-1,-1,1),
	Vector3(-1,-1,-1)
]
var edges=[
	[0,2],
	[2,6],
	[6,4],
	[4,0],
	
	[0,1],
	[2,3],
	[6,7],
	[4,5],
	
	[5,7],
	[1,3],
	[7,3],
	[1,5]
]
#var target = vertices
var viewsize = Vector2(1152,648)
var origin = Vector3(viewsize.x/2,viewsize.y/2,0)
var size = 150
var mouseDelta = Vector2(0,0)
var dragging = false
var mouselast = Vector2()
var sizemult=1
var vel = Vector2.ZERO
var leniency = .01
var acd = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	_rotateall(target,randf()*TAU,Vector3.DOWN,Vector3.ZERO)
	_rotateall(target,randf()*TAU,Vector3.RIGHT,Vector3.ZERO)
	pass # Replace with function body.

#Pengu custom, first beat
func _on_start():
	
	pass

func _on_new_beat():
	sizemult=1.05
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	mouseDelta=get_viewport().get_mouse_position()-mouselast
	mouselast=get_viewport().get_mouse_position()
	vel=vel.move_toward(Vector2.ZERO,delta*2)
	
	if sizemult > 1:
		sizemult-=.005
	else:
		sizemult=1
	if dragging:
		_rotateall(vertices,mouseDelta.x/100,Vector3.DOWN,Vector3.ZERO)
		_rotateall(vertices,mouseDelta.y/100,Vector3.RIGHT,Vector3.ZERO)
	else:
		_rotateall(vertices,vel.x/100,Vector3.DOWN,Vector3.ZERO)
		_rotateall(vertices,vel.y/100,Vector3.RIGHT,Vector3.ZERO)
	acd = _averageclosestdistance(vertices, target)
	queue_redraw()
	pass
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if not dragging and event.pressed:	
			dragging = true
			vel = Vector2.ZERO
			
		# Stop dragging if the button is released.
		if dragging and not event.pressed:
			dragging = false
			vel=mouseDelta

func _draw():
	
	var fcol =Color.AQUAMARINE if acd <leniency else Color.AQUA
	var ccol =Color.GREEN if acd <leniency else Color.RED
	draw_line(Vector2(0,viewsize.y),viewsize,fcol ,viewsize.y*2-acd*viewsize.y*2)
	_shitcube(edges,target,Color.YELLOW)
	_shitcube(edges,vertices,ccol)
	pass

func _shitcube(edg,ver,col): #THIS FUNCTION IS BAD, YOURE GONNA CRY IF YOU USE IT OUTSIDE OF SQUAREINATOR
	for e in edg:
		#var col =Color.from_hsv(0,1,(vertices[e[1]].z + vertices[e[0]].z)/2)
		var a =ver[e[0]]*size*sizemult
		var b =ver[e[1]]*size*sizemult
		a = a.move_toward(Vector3.ZERO,a.z/3)+Vector3(origin)
		b = b.move_toward(Vector3.ZERO,b.z/3)+Vector3(origin)
		draw_circle(Vector2(b.x,b.y),25/2,col)
		draw_line(Vector2(a.x,a.y),Vector2(b.x,b.y),col,25)
	pass

func _rotateall(vert,rotation:float,axis:Vector3,origin:Vector3):
	var i = 0
	for v in vert:
		vert[i] = (v-origin).rotated(axis,rotation)+origin
		i+=1
	pass

func _averageclosestdistance(v1,v2): #THIS FUNCTION ALSO SUCKS,, COPE
	var c =0
	var d = 9999999 #hihihihihihi
	for a in v1:
		for b in v2:
			d= min(d, a.distance_squared_to(b))
		c+=d
	return c/v1.size()

func _on_end_minigame():
	if acd < leniency:
		minigame_state = State.WON
	else:
		minigame_state = State.LOST

func _rendershape(position : Vector3, rotation : Vector3, size : Vector3, mesh : Mesh):
	
	pass
