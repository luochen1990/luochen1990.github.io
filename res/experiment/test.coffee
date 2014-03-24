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

computer_gen = (computer_type) ->
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

	eval("computer#{computer_type}_gen()")


disturbance_gen = (disturbance_type) ->
	disturbance1_gen = () ->
		(user_input) ->
			if Math.random() < 0.5 then 0 else 1 #干扰项(黄色圆)随机出现

	disturbance2_gen = () ->
		choice_cnt = [0, 0]
		(user_input) ->
			ans = if Math.random() < 0.5 then 0 else 1
			choice_cnt[user_input] += 1
			if Math.abs(choice_cnt[0] - choice_cnt[1]) >= 1
				ans = if choice_cnt[0] > choice_cnt[1] then 0 else 1 #干扰项出现在用户偏好的一方
			ans

	disturbance3_gen = () ->
		choice_cnt = [0, 0]
		(user_input) ->
			ans = if Math.random() < 0.5 then 0 else 1
			choice_cnt[user_input] += 1
			if Math.abs(choice_cnt[0] - choice_cnt[1]) >= 1
				ans = if choice_cnt[0] < choice_cnt[1] then 0 else 1 #干扰项出现在用户不偏好的一方
			ans

	eval("disturbance#{disturbance_type}_gen()")

##################################################################

$(document).on 'game-started', (ev, disturbance_type, computer_type, game_round) ->
	$('#game-finished-div').remove()
	$('#game-started-div').remove()
	$('#main-frame').append("""<div id='game-started-div'>
	<div id='score-div' class='row'></span><span class='col-xs-2' style='font-size:20pt'>SCORE:</span><span id='score' class='col-xs-2' style='font-size:20pt'>0</span></div>
	<svg xmlns='http://www.w3.org/2000/svg' version='1.1'>
		<circle id='left-cicle' cx='30%' cy='50%' r='20%' stroke='white' stroke-width='1' fill='blue' />
		<circle id='right-cicle' cx='70%' cy='50%' r='20%' stroke='white' stroke-width='1' fill='blue' />
	</svg>
	</div>""")
	computer = computer_gen(computer_type)
	if disturbance_type > 0
		disturbance = disturbance_gen(disturbance_type)
	result = []
	accept_input = true
	round_start_time = new Date().getTime()
	disturb = null
	log disturbance_type
	log computer_type
	log game_round
	if disturbance_type > 0
		disturb = if Math.random() < 0.5 then 0 else 1
		$(['#left-cicle', '#right-cicle'][disturb]).attr('fill', 'yellow')

	after_got_user_input = (user_input) ->
		if accept_input
			feedback = computer(user_input)
			$('#score').text(Number($('#score').text()) + (feedback - not feedback))
			log user_input
			log feedback
			result.push({
				time: new Date().getTime() - round_start_time
				answer: user_input
				same: feedback
				disturb: disturb
			})
			log result
			if result.length == game_round
				$(document).trigger('game-finished', [result])

			$(['#left-cicle', '#right-cicle'][user_input]).attr('fill', if feedback then 'green' else 'red')
			accept_input = false
			setTimeout((() ->
				$('#left-cicle').attr('fill', 'blue')
				$('#right-cicle').attr('fill', 'blue')
				accept_input = true
				round_start_time = new Date().getTime()
				if disturbance_type > 0
					disturb = disturbance(user_input)
					$(['#left-cicle', '#right-cicle'][disturb]).attr('fill', 'yellow')
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
		"""<table class='table table-striped'>
		<tr><th>#{(k for k, v of result[0]).join('</th><th>')}</th></tr>
		<tr><td>#{((v for k, v of row).join('</td><td>') for row in result).join('</td></tr><tr><td>')}</td></tr>
		</table>"""

	json2csv = (json) ->
		(k for k, v of result[0]).join(',') + '\n' + ((v for k, v of row).join(',') for row in result).join('\n')

	csv2href = (csv) ->
		"data:text/csv;charset=utf-8," + encodeURIComponent(csv)

	result_analysis = (result) ->
		cc = [0, 0]
		fc = [0, 0]
		sc = [0, 0]
		dc = 0
		score = 0
		for i in [0...result.length]
			r = result[i]
			cc[r.answer] += 1
			fc[r.answer] += 1 if i > 0 and r.answer == result[i - 1].answer ^ result[i - 1].same
			sc[r.answer] += 1 if r.same
			dc += r.answer == r.disturb
			score += (r.same - not r.same)
			result[i].score = score
			result[i].left_choice_ratio = cc[0] / (i + 1)
			result[i].right_choice_ratio = cc[1] / (i + 1)
			result[i].left_follow_ratio = fc[0] / (i + 1)
			result[i].right_follow_ratio = fc[1] / (i + 1)
			result[i].left_success_ratio = sc[0] / (i + 1)
			result[i].right_success_ratio = sc[1] / (i + 1)
			result[i].disturb_choosed_ratio = dc / (i + 1)
		result

	download_href = csv2href json2csv result_analysis result

	$('#game-started-div').remove()
	$('#main-frame').append("""<div id='game-finished-div'>
		<a id='download-result' download='result.csv' href='#{download_href}'>[保存实验记录]</a>
		#{json2table result_analysis result}
	</div>""")


$(document).ready () ->
	log 'hello'
	$('#main-frame').addClass('container')
	$('#main-frame').append("""<div id='game-select-div'>
	<input type='number' style='width:100px' id='disturbance_type' min='0' max='3' value='' placeholder='干扰算法ID' />
	<input type='number' style='width:100px' id='computer_type' min='0' max='2' value='' placeholder='机器算法ID' />
	<input type='number' style='width:100px' id='game_round' min='1' max='1000000' value='' placeholder='游戏轮数' />
	<input type='submit' style='width:100px' id='start-game' value='开始游戏' />
	</div>""")
	$('#start-game').on 'click', (ev) ->
		$(document).trigger('game-started', [Number($('#disturbance_type').val()), Number($('#computer_type').val()), Number($('#game_round').val())])

