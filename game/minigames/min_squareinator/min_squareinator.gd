#NOAHAMP, EG-GE
extends Minigame

var sfx = {
	"down":"res://resources/sound/sfx/select.wav",
	"up":"res://resources/sound/sfx/select2.wav"
}

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
var target =vertices.duplicate()

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
#^THIS MAKES A CUBE^

var viewsize = Vector2(1152,648) #VIEWPORT SIZE
var origin = Vector3(viewsize.x/2,viewsize.y/2,0) #OFFSET TO THE WORLD ORIGIN

var mouseDelta = Vector2(0,0) #SPEED OF CURSOR
var dragging = false #LEFT CLICK STATE 
var mouselast = Vector2() 
var sizemult=1 #BEAT HOP AMOUNT
var vel = Vector2.ZERO #ANGULAR VELOCITY
var acd = 0 #AVERAGE CLOSEST DISTANCE, DO NOT USE FOR WIN CONDITION, ONLY USE FOR VISUALS
#USE _checkmatch FOR WIN CONDITION CHECK
var difmesh #MESH FOR THE DIFFICULTY, UNUSED FOR EASY MODE

#EASY MODE PARAMS ARE DEFAULT
var msize = 150 #THE MESH SIZE
var leniency = .4 #ROOM FOR ERROR, DO NOT SET HIGH YOU WILL GET AN INFINITE LOOP
var thickness = 25 #DRAWN LINE THICKNESS



func _ready():
	var mdt = MeshDataTool.new()
	if level != 1: #EASY MODE PARAMS ARE ABOVE
		if level == 2: #MEDIUM MODE PARAMS
			difmesh = $Triangle
			leniency = 0.4
			msize=140
		if level >= 3: #HARD MODE PARAMS
			difmesh = $Triagle
			$Sprite2D.material.set_shader_parameter("shung",16-level*2) #MAKES SHADER CRUNCHIER
			msize=200
			leniency = 0.3
			thickness = 30
		mdt.create_from_surface(difmesh.mesh,0)
	
		vertices.resize(mdt.get_vertex_count())
		vertices.fill(Vector3(0,0,0))
		target=vertices.duplicate()
		
		edges.resize(mdt.get_edge_count())
		edges.fill([0,0])
	
	
	for i in mdt.get_vertex_count():
		vertices[i]=mdt.get_vertex(i)
		
	for i in mdt.get_edge_count():
		edges[i]=[mdt.get_edge_vertex(i,0),mdt.get_edge_vertex(i,1)]
		
	target = vertices.duplicate()
	
	while _checkmatch(vertices,target): #RANDOMLY ROTATE TARGET ROTATION UNTIL IT DOESNT MATCH
		_rotateall(target,randf()*TAU,Vector3.DOWN,Vector3.ZERO)
		_rotateall(target,randf()*TAU,Vector3.RIGHT,Vector3.ZERO)

#Pengu custom, first beat
func _on_start():
	pass

func _on_new_beat():
	sizemult=1.05  #AMOUNT OF BEAT HOP, 1 IS DEFAULT SIZE

func _process(delta):
	
	mouseDelta=get_viewport().get_mouse_position()-mouselast
	mouselast=get_viewport().get_mouse_position()
	vel=vel.move_toward(Vector2.ZERO,delta*2) #REDUCE VELOCITY, FRICTION IS HARDCODED HERE
	
	if sizemult > 1: #BEAT HOP WIND DOWN
		sizemult-=.005
	else:
		sizemult=1
		
	if dragging: #LEFT CLICK IS DOWN
		_rotateall(vertices,mouseDelta.x/100,Vector3.DOWN,Vector3.ZERO)
		_rotateall(vertices,mouseDelta.y/100,Vector3.RIGHT,Vector3.ZERO)
	else: #LEFT CLICK IS UP
		_rotateall(vertices,vel.x/100,Vector3.DOWN,Vector3.ZERO)
		_rotateall(vertices,vel.y/100,Vector3.RIGHT,Vector3.ZERO)
	acd = _averageclosestdistance(vertices, target)
	
	#IF LEFT CLICK ISNT PRESSED, THE ROTATIONS MATCH AND ANGULAR VELOCITY IS SMALL ENOUGH: 
	#SLOWLY SNAP THE POINTS TO WHERE THEY SHOULD BE
	if !dragging and _checkmatch(vertices,target) and vel.length()<0.4:
		_snapto(vertices,target,1)
	
	queue_redraw() #RENDERS THE CURRENT FRAME. 
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if not dragging and event.pressed: #IF LEFT CLICK WASNT DOWN AND IS NOW DOWN
			dragging = true #TELL EVERYONE THAT LEFT CLICK IS DOWN NOW
			play_local_sfx(sfx["down"])
			vel = Vector2.ZERO #STOP THE SHITCUBE FROM ROTATING ON ITS OWN

		if dragging and not event.pressed: #IF LEFT CLICK WAS DOWN BUT ITS NOW UP
			dragging = false #TELL EVERYONE LEFT CLICK IS UP
			
			var matching = _checkmatch(vertices, target)
			if(matching): play_local_sfx(sfx["up"])
			
			vel=mouseDelta #IMPART THE VELOCITY IT LAST HAD WHILE BEING FORCED TO ROTATE

func _draw():
	var fcol =Color.AQUAMARINE if _checkmatch(vertices,target) else Color.AQUA #BG COLOR TERNARY FOR WINCON
	var ccol =Color.GREEN if _checkmatch(vertices,target) else Color.RED #LINE COLOR TERNARY FOR WINCON
	draw_line(Vector2(-10,viewsize.y),viewsize,fcol ,viewsize.y*2-acd*viewsize.y*2) #DRAW BG, BG RAISES WITH CLOSENESS
	_shitcube(edges,target,Color.YELLOW) #DRAW THE TARGET SHAPE 
	_shitcube(edges,vertices,ccol) #DRAW THE MAIN SHAPE
	pass

func _shitcube(edg,ver,col): #DRAWS THE SHAPES, VERY BAD FUNC, SORRY
	for e in edg: #FOR ALL EDGES
		var a =ver[e[0]]*msize*sizemult #MOVE FIRST VERTEX OF EDGE AWAY FROM 0,0 TO EMULATE SIZE INCREASE
		var b =ver[e[1]]*msize*sizemult #MOVE SECOND VERTEX OF EDGE AWAY FROM 0,0 TO EMULATE SIZE INCREASE
		a = a.move_toward(Vector3.ZERO,a.z/3)+Vector3(origin) #APPLY PERSPECTIVE
		b = b.move_toward(Vector3.ZERO,b.z/3)+Vector3(origin) #APPLY PERSPECTIVE
		draw_circle(Vector2(b.x,b.y),thickness/2,col) #DRAW CORNERS (NOT RELIABLE)
		draw_line(Vector2(a.x,a.y),Vector2(b.x,b.y),col,thickness) #DRAW EDGES

func _rotateall(vert,rotation:float,axis:Vector3,origin:Vector3): #ROTATES SHAPE
	var i = 0 
	for v in vert:
		vert[i] = (v-origin).rotated(axis,rotation)+origin #SUBTRACT ORIGIN THEN ROTATE THEN ADD ORIGIN
		i+=1
	pass

func _averageclosestdistance(v1,v2): #THIS FUNCTION ALSO SUCKS, GOOD THING ITS DEPRECATED
	var c =0
	var d = INF 
	for a in v1:
		c=0 #RESET OF VARIABLES REQUIRED
		d=INF 
		for b in v2:
			d= min(d, a.distance_squared_to(b))
		c+=sqrt(d)
	return c/v1.size()
	
func _checkmatch(v1,v2): #ITERATE OVER EVERY VERTEX PAIR, CHECK IF ALL OF THEM ARE WITHIN MARGIN OR ERROR 
	var c =0
	var d = INF 
	for a in v1:
		c=0
		d=INF
		for b in v2:
			d= min(d, a.distance_squared_to(b))
		if d > leniency: return false
	return true
	
func _snapto(v1,v2,d): #MOVE CLOSEST POINTS OF V1 TO V2 BY DISTANCE D
	var c 
	var e = INF 
	var i=0
	for a in v1:
		c=0
		e=INF
		for b in v2:
			if a.distance_squared_to(b) < e:
				e=a.distance_squared_to(b)
				c=b
		v1[i] = a.move_toward(c,d*e+0.01)
		i+=1

func _on_end_minigame():
	if _checkmatch(vertices,target): #IF SHAPES ARE CURRENTLY MATCHING
		minigame_state = State.WON #CHICKEN DINNER
	else:
		minigame_state = State.LOST #try again, i believe in you

