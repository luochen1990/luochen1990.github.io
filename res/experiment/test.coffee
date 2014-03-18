WAITING_SECONDS = 0.5

##################################################################

log = (it) -> console.log(JSON.stringify(it))
err = (it) -> alert(JSON.stringify(it))

#sleep = (milliseconds) ->
#	start = new Date().getTime()
#	null while (new Date().getTime() - start) < milliseconds

#events = {}
#
#wait = (event_name) ->
#	check = () ->
#		if events[event_name]
#			events[event_name]
#		else
#			setTimeOut(10, check)
#	check()
#
#register = (event_name) ->
#	if events[event_name] == null
#		events[event_name] = []
#	$(document).bind event_name, (ev, param...) ->
#		events[event_name].add([ev, param...])

##################################################################

#user_gen = () ->
#	iter = (computer_feedback) ->
#		wait_for_click_event
#		user_input

computer0_gen = () ->
	(user_input) ->
		ans = if Math.random() < 0.5 then 0 else 1
		user_input == ans

computer1_gen = () ->
	choice_cnt = [0, 0]
	(user_input) ->
		ans = if Math.random() < 0.5 then 0 else 1
		choice_cnt[user_input] += 1
		if Math.abs(choice_cnt[0] - choice_cnt[1]) >= 2
			ans = if choice_cnt[0] < choice_cnt[1] then 0 else 1
		user_input == ans

computer2_gen = () ->
	success_cnt = [0, 0]
	(user_input) ->
		ans = if Math.random() < 0.5 then 0 else 1
		if Math.abs(success_cnt[0] - success_cnt[1]) >= 1
			ans = if success_cnt[0] < success_cnt[1] then 0 else 1
		if user_input == ans
			success_cnt[user_input] += 1
		user_input == ans

$(document).on 'game-started', (ev, game_type, game_id, game_round) ->
	$('body').append("""<svg xmlns="http://www.w3.org/2000/svg" version="1.1">
		<circle id="left-cicle" cx="30%" cy="50%" r="20%" stroke="white" stroke-width="1" fill="blue" />
		<circle id="right-cicle" cx="70%" cy="50%" r="20%" stroke="white" stroke-width="1" fill="blue" />
	</svg>""")
	computer = eval("computer#{game_id}_gen()")
	result = []
	accept_input = true
	round_start_time = new Date().getTime()
	log game_type
	log game_id
	log game_round
	if game_type == 1
		log 'aaaaaa'
		if Math.random() < 0.5
			$('#left-cicle').attr('fill', 'yellow')
			log 'bbbbbbbbbb'
		else
			$('#right-cicle').attr('fill', 'yellow')
			log 'ccccccccccc'

	after_got_user_input = (user_input) ->
		if accept_input
			feedback = computer(user_input)
			log user_input
			log feedback
			result.push({
				time: new Date().getTime() - round_start_time
				answer: user_input
				same: feedback
			})
			log result
			if result.length == game_round
				$(document).trigger('game-finished', [result])

			$(['#left-cicle', '#right-cicle'][user_input]).attr('fill', if feedback then 'green' else 'red')
			accept_input = false
			setTimeout((() ->
				$(['#left-cicle', '#right-cicle'][user_input]).attr('fill', 'blue')
				accept_input = true
				round_start_time = new Date().getTime()
				if game_type == 1
					if Math.random() < 0.5
						$('#left-cicle').attr('fill', 'yellow')
						$('#right-cicle').attr('fill', 'blue')
					else
						$('#left-cicle').attr('fill', 'blue')
						$('#right-cicle').attr('fill', 'yellow')
			), WAITING_SECONDS * 1000)

	on_cicle_click = (ev) ->
		after_got_user_input({'left-cicle': 0, 'right-cicle': 1}[ev.target.id])

	on_keydown = (ev) ->
		char = if typeof ev.which == 'number' then ev.which else ev.keyCode
		if char in [37, 39]
			after_got_user_input(if char == 37 then 0 else 1)

	document.onkeydown = on_keydown
	$(id).on('click', on_cicle_click) for id in ['#left-cicle', '#right-cicle']


$(document).on 'game-finished', (ev, result) ->
	json2table = (json) ->
		"<table class='table table-striped'><tr><td>#{((v for k, v of row).join('</td><td>') for row in result).join('</td></tr><tr><td>')}</td></tr></table>"

	json2csv = (json) ->
		((v for k, v of row).join(',') for row in result).join('\n')

	csv2href = (csv) ->
		"data:text/csv;charset=utf-8," + encodeURIComponent(csv)

	result_analysis = (result) ->
		cc = [0, 0]
		fc = [0, 0]
		for i in [0...result.length]
			r = result[i]
			cc[r.answer] += 1
			if i > 0 and r.answer == result[i - 1].answer ^ result[i - 1].same
				fc[r.answer] += 1
			result[i].left_choice_ratio = cc[0] / (i + 1)
			result[i].right_choice_ratio = cc[1] / (i + 1)
			result[i].left_follow_ratio = fc[0] / (i + 1)
			result[i].right_follow_ratio = fc[1] / (i + 1)
		result

	download_href = csv2href json2csv result_analysis result

	$('svg').remove()
	$('div').remove()
	$('body').append("<a id='download-result' download='result.csv' href='#{download_href}'>[保存实验记录]</a>")
	$('body').append(json2table result_analysis result)


$(document).ready () ->
	log 'hello'
	$('body').append('''<div>
	<input type="number" id="game_type" min="0" max="1" value="0" placeholder="game type" />
	<input type="number" id="game_id" min="0" max="2" value="0" placeholder="game id" />
	<input type="number" id="game_round" min="1" max="1000000" value="4" placeholder="game round" />
	<input type="submit" id="start-game" value="开始游戏" />
	</div>''')
	$('#start-game').on 'click', (ev) ->
		$(document).trigger('game-started', [Number($('#game_type').val()), Number($('#game_id').val()), Number($('#game_round').val())])

