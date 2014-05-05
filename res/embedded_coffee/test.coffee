########################### utils ###############################

window.log = (args...) ->
	op = if args.slice(-1)[0] in ['log', 'warn', 'error'] then args.pop() else 'log'
	window.logs = window.logs or []
	ball = []
	for f in args
		if typeof f == 'function'
			expr = f.toString().replace(/\s*function\s*\(\s*\)\s*{\s*return\s*([^]*);\s*}/, '$1')
			expr = expr.replace /[\r\n]{1,2}\s*/g, '' if expr.length <= 100
			ball.push("## #{expr} ==>", f())
		else
			ball.push('##', f)
	console[op] ball...
	window.logs.push(ball)

########################### functions ###############################

window.dict = (pairs) -> #constract object from list of pairs; recover the lack of dict comprehensions
	d = {}
	d[k] = v for [k, v] in pairs
	d

window.size = (obj) -> Object.keys(obj).length

window.reversed = (arr) ->
	arr.slice().reverse()

window.accumulate = (fruit, nutri, foo) ->
	fruit = foo(fruit, it) for it in nutri
	fruit

window.sum = (arr) ->
	r = 0
	r += x for x in arr
	r

window.square = (n) -> n * n

window.zip = (a, b) ->
	len = Math.min(a.length, b.length)
	([a[i], b[i]] for i in [0...len])

window.all = (arr, f) ->
	return false for x in arr when not f(x)
	true

window.any = (arr, f) ->
	return true for x in arr when f(x)
	false

######################### type trans #############################

window.int = (s) -> if /^-?[0-9]+$/.test(s) then parseInt(s) else null
window.float = (s) -> if /^-?[0-9]*(\.[0-9]+)?([eE]-?[0-9]+)?$/.test(s) then parseFloat(s) else null
window.str = (x) -> x + ''
window.json = (it) -> JSON.stringify(it)
window.obj = (s) -> JSON.parse(s)

window.sign = (x) -> (x > 0) - (x < 0)

###################### string formating ##########################

String.prototype.format = (args) ->
	this.replace /\{(\w+)\}/g, (m, i) -> if args[i]? then args[i] else m

String.prototype.repeat = (n) ->
	r = ''
	r += this for i in [0...n]
	r

window.url_encode = (obj) ->
	("#{encodeURIComponent(k)}=#{encodeURIComponent(v)}" for k, v of obj).join('&')

window.sleep = (seconds, callback) -> setTimeout(callback, seconds * 1000)

########################### pseudo-random ###############################

window.random_gen = (seed) ->
	->
		x = Math.sin(seed++) * 10000
		x - Math.floor(x)

window.ranged_random_gen = (range, seed) ->
	random = random_gen(seed)
	->
		Math.floor(random() * range)

##################################################################

init_coffee_editor = (coffee_code_div, js_code_div) ->
	_js_code = ''
	_compile = () ->
		_js_code = CoffeeScript.compile($(coffee_code_div).val(), {bare: true})
		$(js_code_div).val(_js_code) if js_code_div
	_eval = () ->
		eval(_js_code)

	count_indent = (line, tab) ->
		c = 0
		i = 0
		while i < line.length
			if line.substr(i, tab.length) == tab
				c += 1
				i += tab.length
			else
				break
		c

	tab = ' '.repeat(4)

	$(coffee_code_div).on 'keydown', (e) ->
		#log json [e.keyCode, e.shiftKey]
		if e.keyCode in [9, 13, 8]
			e.preventDefault()
			text = this.value
			start = this.selectionStart
			end = this.selectionEnd
			if e.keyCode == 9 and start != end
				while start-1 >= 0 and text[start-1] != '\n'
					start -= 1

			selected = text.slice(start, end)
			before = text.slice(0, start)
			after = text.slice(end)

			if e.keyCode == 9 #tab
				if start == end
					this.value = before + tab + after
					this.selectionStart = this.selectionEnd = start + tab.length
				else
					#log json [e.keyCode, e.shiftKey]
					lines = selected.split('\n')
					cnt = 0
					if e.shiftKey
						for i in [0...lines.length]
							if lines[i].slice(0, tab.length) == tab
								lines[i] = lines[i].slice(tab.length)
								cnt -= tab.length
					else
						for i in [0...lines.length]
							lines[i] = tab + lines[i]
							cnt += tab.length

					selected = lines.join('\n')
					#log before
					#log selected
					#log after
					this.value = before + selected + after
					this.selectionStart = start
					this.selectionEnd = end + cnt
			if e.keyCode == 8 #backspace
				if start == end
					c = if before.slice(-tab.length) == tab then tab.length else 1
					this.value = before.slice(0, -c) + after
					this.selectionStart = this.selectionEnd = start - c
				else
					this.value = before + after
					this.selectionStart = this.selectionEnd = start
			if e.keyCode == 13 #enter
				if e.shiftKey
					_compile()
					_eval()
				else
					if before.length == 0
						#log 'aaaa'
						this.value = before + '\n' + after
						this.selectionStart = this.selectionEnd = start + 1
					else
						lines = before.split('\n')
						last_line = lines[lines.length - 1]
						#log last_line
						indent = count_indent(last_line, tab)
						indent += 1 if /(^\s*(for|while|until|if|unless) )|((\(|\[|\{|[-=]>)$)/.test last_line
						#log indent
						inserted = '\n' + tab.repeat(indent)
						#log inserted
						this.value = before + inserted + after
						this.selectionStart = this.selectionEnd = start + inserted.length

	coffee_code: () ->
		$(coffee_code_div).val()
	js_code: () ->
		_compile()
		_js_code
	run: () ->
		_compile()
		_eval()

##################################################################

$(document).ready ->
	editor = init_coffee_editor('#code-block', '#js-block')

	$('#run-button').on 'click', ->
		editor.run()

