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

vec.mix = (va , vb , k) ->
	vec.add(va , vec.mul(vec.sub(vb , va) , k))

log = (it) -> console.log(JSON.stringify(it))
err = (it) -> alert(JSON.stringify(it))

####

############################################################

pos_size0 = (frame) ->
	size0 = [280 , 420]
	size1 = [320 , 480]
	pos0 = [size0[0] * 0.5, 40]
	pos1 = [size0[0] , 0]
	if frame < 50
		pos = vec.mix(pos0 , pos1 , frame/50)
		size = vec.mix(size0 , size1 , frame/50)
		[pos... , size...]
	else
		pos = vec.mix(pos1 , pos0 , (frame-50)/50)
		size = vec.mix(size1 , size0 , (frame-50)/50)
		[pos... , size...]

pos_size1 = (frame) ->
	size0 = [280 , 420]
	size1 = [240 , 360]
	pos0 = [size0[0] * 0.5, 40]
	pos1 = [0 , 80]
	if frame < 50
		pos = vec.mix(pos0 , pos1 , frame/50)
		size = vec.mix(size0 , size1 , frame/50)
		[pos... , size...]
	else
		pos = vec.mix(pos1 , pos0 , (frame-50)/50)
		size = vec.mix(size1 , size0 , (frame-50)/50)
		[pos... , size...]

canvas = document.getElementById('canv')
[width, height] = [canvas.width, canvas.height]
pen = canvas.getContext("2d")
img = (document.getElementById("p#{i}") for i in [1..6])

anim = (img0 , img1) ->
	window.anim_switch = (frame) ->
		pen.clearRect(0, 0, width, height)
		
		if frame < 50
			pen.drawImage(img1 , pos_size1(frame)...)
			pen.drawImage(img0 , pos_size0(frame)...)
		else
			pen.drawImage(img0 , pos_size0(frame)...)
			pen.drawImage(img1 , pos_size1(frame)...)
		
		frame += 1
		if frame < 100
			setTimeout("window.anim_switch(#{frame + 1})", 20)
	window.anim_switch(0)


############################################################

pen.drawImage(img[0] , pos_size0(0)...)
id = 0

$('#next').click ->
	id2 = (id + 1) % img.length
	anim(img[id] , img[id2])
	id = id2

$('#prev').click ->
	id2 = (id + img.length - 1) % img.length
	anim(img[id] , img[id2])
	id = id2
