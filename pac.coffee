FindProxyForURL = do ->
	proxys =
		aliyun: 'SOCKS5 127.0.0.1:12211'
		shadowsocks: 'SOCKS5 127.0.0.1:1080'
		goagent: 'PROXY 127.0.0.1:8087'
		direct: 'DIRECT'

	domain_groups =
		company_inner_domain_names:
			ways: 'direct'
			list: [
				't1.com'
				'sohuno.com'
				'no.sohu.com'
			]
		blocked_by_company:
			ways: 'aliyun direct'
			list: [
				'tmall.com'
				'amazon.*'
				'jd.com'
				'paipai.com'
				'meituan.com'
				'taobao.com'
				'appspot.com'
				'360buy.com'
			]
		blocked_by_gfw:
			ways: 'shadowsocks direct'
			list: [
				'angularjs.org'
				'getpocket.com'
				'dropbox.com'
				'fastly.net'
				'sf.net'
				'sourceforge.net'
				'sstatic.net'
				'stackoverflow.com'
				'wikipedia.org'
				'googleapis.com'
				'gmail.com'
				'mail.google.com'
				'plus.google.com'
				'googleusercontent.com'
				'google.com'
				'gstatic.com'
				#'accounts.google.com'
				#'chrome.google.com'
				#'mail.google.com'
				#'plus.google.com'
				#'maps.google.com'
				'facebook.com'
				'twitter.com'
				'atgfw.org'
				'blogspot.com'
			]

	match = (url, domain) ->
		shExpMatch(url, "*://*.#{domain}/*") || shExpMatch(url, "*://#{domain}/*")

	any = (iter, f=(x)->(x)) ->
		return true for x in iter when f(x)
		false

	proxy = (ways) ->
		(proxys[proxy_name] for proxy_name in ways.split(' ')).join('; ')

	(url, host) ->
		for group_name, group of domain_groups
			if any(group.list, (domain) -> match(url, domain))
				return proxy group.ways
		return proxy 'direct shadowsocks'

