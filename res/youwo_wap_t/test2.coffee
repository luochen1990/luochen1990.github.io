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

weight = (arr) ->
	tot = sum(arr)
	(x) -> x / tot

position = (xs , xt , x) -> (x - xs) / (xt - xs)

log = (it) -> console.log(JSON.stringify(it))
err = (it) -> alert(JSON.stringify(it))
assert = (flag) -> if not flag then alert("assertion error") and (1/0)

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

b_search = (f , xs , xt , midx , y_lefter , x_close_enough) ->
	iter = (xl , xu , yl , yu , y) ->
		if x_close_enough(xl , xu)
			[xl , xu]
		else
			xm = midx(xl , xu)
			ym = f(xm)
			if y_lefter(y , ym)
				iter(xl , xm , yl , ym , y)
			else
				iter(xm , xu , ym , yu , y)
	(y) ->
		iter(xs , xt , f(xs) , f(xt) , y)

#testbs = b_search(square , 0 , 10000 , ((u, v) -> (u + v) / 2) , ((y , z) -> y < z) , ((u,v)->(v-u<0.001)))
#err testbs(2)
#err [[y , testbs(y)] for y in [1..10]]

array_b_search = (arr , reversed = false) ->
# y in [ arr[x0], arr[x1] ) where [x0, x1] = array_b_search(arr)(y)
	if reversed
		f = (x) -> if x == -1 then Infinity else if x == arr.length then -Infinity else arr[x]
		y_lefter = (y0 , y1) -> y0 > y1
	else
		f = (x) -> if x == -1 then -Infinity else if x == arr.length then Infinity else arr[x]
		y_lefter = (y0 , y1) -> y0 < y1
	midx = (x0, x1) -> Math.floor((x0 + x1) / 2)
	x_close_enough = (x0 , x1) -> x1 - x0 <= 1
	b_search(f, -1, arr.length, midx, y_lefter, x_close_enough)

#testabs = array_b_search([1.1 , 2.2 , 3.3 , 4.4])
#testabs2 = array_b_search([4.4 , 3.3 , 2.2 , 1.1] , reversed = true)
#err [[y , testabs(y)] for y in [0 , 1.1 , 2 , 2.2 , 3 , 3.3 , 4 , 4.4 , 5]]

polyline = (mix) ->
	(t_v...) ->
		n = t_v.length
		assert(n >= 2)
		t_ = (it[0] for it in t_v)
		v_ = (it[1] for it in t_v)
		t_i = array_b_search(t_)
		line = (i , j) ->
			(t) -> mix(v_[i], v_[j], position(t_[i], t_[j], t))
		(t) ->
			[i0 , i1] = t_i(t)
			expand_line = if i0 < 0 then line(0, 1) else if i1 >= n then line(n-2, n-1) else line(i0 , i1)
			expand_line(t)

#testpolyline = polyline((a,b,k)->(a+k*(b-a)))([0, 2], [0.9, 4] , [1, 100])
#err testpolyline(0.99)

vec.polyline = (t_p...) ->
	polyline(vec.mix)(t_p...)

#testpolyline = vec.polyline([0, [-1,-1]] , [1, [2,2]])
#err testpolyline(1)

animate = (draw , clear , status , duration , fps = 50) ->
	frame_num = duration * fps
	frame_interval = 1000 / fps
	->
		anim = (frame_id) ->
			clear()
			draw(status(frame_id / frame_num))
			if frame_id < frame_num
				setTimeout((-> anim(frame_id + 1)), frame_interval)
		anim(0)

####

############################################################

canvas = document.getElementById('canv')
[width, height] = [canvas.width, canvas.height]
pen = canvas.getContext("2d")
img = (document.getElementById("p#{i}") for i in [1..3])

switch_anim = (img0 , img1) ->
	draw = (st) ->
		if not st.flipped
			pen.drawImage(img1 , st.pos1... , st.sz1...)
			pen.drawImage(img0 , st.pos0... , st.sz0...)
		else
			pen.drawImage(img0 , st.pos0... , st.sz0...)
			pen.drawImage(img1 , st.pos1... , st.sz1...)
	
	clear = ->
		pen.clearRect(0, 0, width, height)
	
	pos = [[0 , 80] ,[140 , 40] ,[280 , 0]]
	sz = [[240 , 360] ,[280 , 420] ,[320 , 480]]
	[p0f,p1f,s0f,s1f] = (vec.polyline([0, a[1]], [0.5, a[k]], [1, a[1]]) for [a, k] in cartesian_product([pos, sz], [2, 0]))
	status = (k) ->
		flipped: (k > 0.5)
		pos0: p0f(k)
		pos1: p1f(k)
		sz0: s0f(k)
		sz1: s1f(k)
	animate(draw, clear, status, 1)()

############################################################

pen.drawImage(img[0] , [140 , 40]... , [280 , 420]...)
id = 0

$('#next').click ->
	id2 = (id + 1) % img.length
	switch_anim(img[id] , img[id2])
	id = id2

$('#prev').click ->
	id2 = (id + img.length - 1) % img.length
	switch_anim(img[id] , img[id2])
	id = id2
