init_coffee_editor = (coffee_code_div, js_code_div) ->
	$(coffee_code_div).css('tab-size': '4', '-moz-tab-size': '4', '-o-tab-size': '4')
	_js_code = ''
	_compile = () ->
		_js_code = CoffeeScript.compile($(coffee_code_div).val(), {bare: true})
		$(js_code_div).val(_js_code) if js_code_div
		return null
	_eval = () ->
		try
			eval(_js_code)
		catch e
			alert e
			throw e

	$(coffee_code_div).on 'run', ->
		log.histories.splice(0, Infinity)
		_compile()
		_eval()

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

	#tab = ' '.repeat(4)
	tab = '\t'

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
				if e.shiftKey or e.ctrlKey
					$(coffee_code_div).trigger 'run'
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

	coffee_code: (s) ->
		if s?
			$(coffee_code_div).val(s)
		else
			$(coffee_code_div).val()
	js_code: () ->
		_compile()
		_js_code

##################################################################

storage =
	read: -> ''
	write: ->
	#read: -> obj(localStorage.data ? '{}')
	#write: (data) -> localStorage.data = json(data)

is_empty_item = (it) ->
	return true if not it?
	return true if it instanceof Array and it.length == 0
	return true if typeof it is 'string' and it.length == 0
	return false

filter_empty_item = (d) ->
	r = {}
	(r[k] = v) for k, v of d when not is_empty_item v
	r

$(document).ready ->
	editor = init_coffee_editor('#code-block', '#js-block')

	data = Object.extend(uri_decoder(obj)(location.search), storage.read(), libs: [], code: '')
	console.log 'data.libs:', data.libs
	#log -> '\n' + data.code
	storage.write(data)
	for url in data.libs
		$.getScript(url)
	editor.coffee_code(data.code)

	$('#code-block').on 'run', ->
		data.code = editor.coffee_code()
		storage.write(data)
		$('#output-area').val(log.histories.map((xs) -> xs.join(' ')).join('\n'))

	$('#run-button').on 'click', ->
		$('#code-block').trigger 'run'

	$('#load-lib-button').on 'click', ->
		url = $('#lib-to-load').val()
		data.libs = data.libs.concat [url]
		storage.write(data)
		$.getScript(url)

	$('#get-url').on 'click', ->
		data.code = editor.coffee_code()
		storage.write(data)
		location.search = uri_encoder(json)(filter_empty_item data)

	$('#show-js-button').on 'click', ->
		log -> 'AA'
		if $('#js-block').css('display') == 'none'
			$('#js-block').css('display': 'inline-block')
		else
			$('#js-block').css('display': 'none')

