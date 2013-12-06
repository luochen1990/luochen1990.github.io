sum = (n) ->
	r = 0
	r += x for x in n
	r

square = (n) -> n * n

best = (ls , better) ->
	rext = null
	(rext = if (not rext? or better(it , rext)) then it else rext) for it in ls
	rext

cartesian_product = (la , lb) ->
	r = []
	r.push([x, y]) for y in lb for x in la
	r

random_gen = (seed) ->
	->
		x = Math.sin(seed++) * 10000
		x - Math.floor(x)

ranged_random_gen = (range, seed) ->
	random = random_gen(seed)
	->
		Math.floor(random() * range)

log = (it) -> console.log(JSON.stringify(it))
err = (it) -> alert(JSON.stringify(it))

####

simple_dye = (data) ->
	(n) -> 'c1'

simple_layout = (data, dye, width, height) ->
	n = Math.ceil(Math.sqrt(data.node.length))
	m = {}
	for i in [0..n]
		for j in [0..n]
			if i * n + j < data.node.length
				m[data.node[i*n+j]] = [(j+1)/(n+1)*width,(i+1)/(n+1)*height]
	(n) -> m[n]

zero_layout_iter = (data, dye, width, height, layout) ->
	-> layout

simple_layout_iter = (data, dye, width, height, layout) ->
	sparsity = Math.sqrt(width * height / data.node.length) * 0.5
	adj = {}; adj[n] = [] for n in data.node
	for e in data.edge
		adj[e[0]].push(e[1])
		adj[e[1]].push(e[0])
	
	vec =
		zero: [0, 0]
		onex: [1, 0]
		oney: [0, 1]
		add: (va, vb) -> [va[0] + vb[0] , va[1] + vb[1]]
		opp: (v) -> [-v[0] , -v[1]]
		sub: (va, vb) -> [va[0] - vb[0] , va[1] - vb[1]]
		sum: (vs) -> [sum(v[0] for v in vs), sum(v[1] for v in vs)]
		mul: (va, k) -> [va[0] * k , va[1] * k]
		mul2: (va, vb) -> [va[0] * vb[0] , va[1] * vb[1]]
		len: (v) -> Math.sqrt(square(v[0]) + square(v[1]))
		norm: (v) ->
			len = Math.sqrt(square(v[0]) + square(v[1]))
			if len > 1e-8 then [v[0] / len, v[1] / len] else [0, 0]
		rot: (v) -> [-v[1], v[0]]
	
	st = {}; st[n] = {a:[0,0], v:[0,0], p:layout(n)} for n in data.node
	
	Fa = (na, nb) ->
		delta = vec.sub(st[nb].p, st[na].p)
		dir = vec.norm(delta)
		dis = vec.len(delta)
		vec.mul(dir, 0.0005 * Math.pow(Math.max(0, dis - sparsity), 1))
	
	Fr = (na, nb) -> #[0.001 * sparsity , 0.001 * sparsity]
		delta = vec.sub(st[na].p, st[nb].p)
		dir = vec.norm(delta)
		dis = vec.len(delta)
		vec.mul(dir, 0.5 * Math.pow(dis , -1))

	Fl = (n) ->
		delta = st[n].v
		dir = vec.norm(delta)
		dis = vec.len(delta)
		vec.mul(vec.opp(dir), 0.001 * sparsity)

	#Fl = (n) -> [0, 0]
	#    f = [0, 0]
	#	dir = [1, 0]; pos = [0, 0]
	#	for i in [0..3]
	#		delta = vec.mul(dir, [width, height][i % 2])
	#		dir = vec.rot(dir)
	#		
	#		dis = Math.abs(vec.sub(st[n].p, pos)[(i+1) % 2])
	#		fi = vec.mul(dir, Math.pow(dis , -1.8))
	#		f = vec.add(f, fi)
	#		
	#		pos = vec.add(pos , delta)
	#	f
	
	normalize = (points) ->
		[L, R, U, D] = (best((p[i] for p in points), better) for [i, better] in cartesian_product([0, 1], [((a, b) -> (a < b)) , ((a, b) -> (a > b))]))
		norm1d = (lower, upper) ->
			(x) -> (x - lower) / (upper - lower)
		[normx , normy] = [norm1d(L, R) , norm1d(U, D)]
		(p) -> [normx(p[0]), normy(p[1])]
	
	placer = (norm) ->
		padding = vec.mul(vec.norm([width, height]), sparsity)
		region = vec.sub([width, height] , vec.mul(padding, 2))
		(p) -> vec.add(padding , vec.mul2(norm(p), region))
	
	->
		for na in data.node
			fa = vec.sum(Fa(na, nb) for nb in adj[na] when nb != na)
			fr = vec.sum(Fr(na, nb) for nb in data.node when nb != na)
			fl = Fl(na)
			st[na].a = vec.sum [fa , fr , fl]
			st[na].v = vec.add(st[na].v, st[na].a)
			st[na].p = vec.add(st[na].p, st[na].v)
		
		trans = placer(normalize(st[n].p for n in data.node))
		
		#st[n].p = trans(st[n].p) for n in data.node
		#(n) -> st[n].p
		(n) -> trans(st[n].p)

simple_draw = (data, layout, dye, width, height, pen) ->
	radius = Math.sqrt(width * height / data.node.length) * 0.15
	pen.fillStyle="#FF0000"
	pen.strokeStyle="#FF2000"
	
	draw_node = (node) ->
		p = layout(node)
		pen.beginPath()
		pen.arc(p[0],p[1],radius,0,Math.PI*2,true)
		pen.closePath()
		pen.fill()
	
	draw_edge = (edge) ->
		[s, t] = [layout(edge[0]), layout(edge[1])]
		#err ([s ,t])
		pen.beginPath()
		pen.moveTo(s[0], s[1])
		pen.lineTo(t[0], t[1])
		pen.closePath()
		pen.stroke()
	
	draw_node(n) for n in data.node
	draw_edge(e) for e in data.edge

############################################################

data_gen = (random_seed, density) ->
	random = random_gen(random_seed)
	v = 1 + Math.floor(random() * 30)
	edge = []
	for i in [1..v]
		for j in [i+1..v]
			if Math.floor(random() * v) < (Math.log(v) / Math.LN2) * density
				edge.push([i, j])
	node: (x for x in [1..v])
	edge: edge

############################################################

data = data_gen(7 , 0.1)
#data =
#	node: ['aa', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']
#	edge: [
#		['aa', 'g']
#		['aa', 'b']
#		['aa', 'f']
#		['b', 'c']
#		['c', 'd']
#		['d', 'j']
#		['h', 'k']
#		['h', 'l']
#		['h', 'm']
#	]
log data.node.length
log data.edge.length


canvas = document.getElementById('canv')
[width, height] = [canvas.width, canvas.height]
pen = canvas.getContext("2d")

dye_style = simple_dye
layout_style = simple_layout

layout_iter = simple_layout_iter
draw = simple_draw

############################################################

if not dye?
	dye = dye_style(data)

if not layout?
	layout = layout_style(data, dye, width, height)

draw(data, layout, dye, width, height, pen)

if layout_iter?
	iter = layout_iter(data, dye, width, height, layout)
	window.redraw = ->
		layout = iter()
		#console.log(JSON.stringify(layout(data.node[0])))
		pen.clearRect(0, 0, width, height)
		draw(data, layout, dye, width, height, pen)
	setInterval("redraw()", 20)

############################################################

window.graph =
	data : data
	layout : layout
	dye : dye

