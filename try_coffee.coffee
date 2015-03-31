init_coffee_editor = (coffee_code_div, js_code_div) ->
	$(coffee_code_div).css('tab-size': '4', '-moz-tab-size': '4', '-o-tab-size': '4')
	_js_code = ''
	_compile = () ->
		try
			_js_code = CoffeeScript.compile($(coffee_code_div).val(), {bare: true})
			$(js_code_div).val(_js_code) if js_code_div
		catch e
			alert e
			throw e
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
	read: -> obj(localStorage.data ? '{}')
	write: (data) -> localStorage.data = json(data)

is_empty_item = (it) ->
	return true if not it?
	return true if it instanceof Array and it.length == 0
	return true if typeof it is 'string' and it.length == 0
	return false

filter_empty_item = (d) ->
	r = {}
	(r[k] = v) for k, v of d when not is_empty_item v
	r

decode_search = uri_decoder(obj)
encode_search = uri_encoder(json)
decode_hash = (b64) -> obj(atob(b64) or 'null')
encode_hash = (s) -> btoa json s

editor = null
_status = {}
init_status = ->
	{libs, code} = decode_search(location.search)
	_status =
		libs: (libs ? [])
		code: (decode_hash(location.hash[1...]) ? code ? "log -> 'hello, coffee-mate!'")
	log -> _status
	if _status.code?
		location.hash = encode_hash _status.code
		location.search = if _status.libs.length > 0 then encode_search libs: _status.libs else ''
	editor.coffee_code(_status.code)
	console.log 'libs: ', _status.libs
	for url in _status.libs
		$.getScript(url)
set_status = (d) ->
	_status = libs: (d.libs ? []), code: d.code
	location.hash = encode_hash _status.code
	location.search = if _status.libs.length > 0 then encode_search libs: _status.libs else ''
set_libs = (libs) ->
	_status.libs = libs ? []
	location.search = if _status.libs.length > 0 then encode_search libs: _status.libs else ''
set_code = (code) ->
	_status.code = code ? ''
	location.hash = encode_hash _status.code

$(document).ready ->
	editor = init_coffee_editor('#code-block', '#js-block')
	do init_status

	$(window).on 'hashchange', ->
		_status.code = decode_hash(location.hash[1...])
		editor.coffee_code(_status.code)
		$('#code-block').trigger 'run'

	$('#code-block').on 'run', ->
		set_code editor.coffee_code()
		storage.write(_status)
		$('#output-area').val(log.histories.map((xs) -> xs.join(' ')).join('\n'))

	$('#run-button').on 'click', ->
		$('#code-block').trigger 'run'

	$('#load-lib-button').on 'click', ->
		url = $('#lib-to-load').val()
		set_libs _status.libs.concat [url]
		storage.write(_status)
		$.getScript(url)
 
	#$('#get-url').on 'click', ->
	#	data.code = editor.coffee_code()
	#	storage.write(data)
	#	location.search = '' if location.search.length > 0
	#	location.hash = encode(filter_empty_item data)

	$('#show-js-button').on 'click', ->
		log -> 'AA'
		if $('#js-block').css('display') == 'none'
			$('#js-block').css('display': 'inline-block')
		else
			$('#js-block').css('display': 'none')

	$('#download-code').on 'click', ->
		$('#download-code').attr(href: "data:text/coffeescript;base64,#{btoa _status.code}")

	#$('#load-storage').on 'click', ->
	#	storage.write _status
	#	set_status storage.read()

window.onload = ->
	$('#code-block').trigger 'run'

