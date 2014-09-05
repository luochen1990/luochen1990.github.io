// Generated by CoffeeScript 1.7.1
var FindProxyForURL;

FindProxyForURL = (function() {
  var any, domain_groups, match, proxy, proxys;
  proxys = {
    aliyun: 'SOCKS5 127.0.0.1:12211',
    shadowsocks: 'SOCKS5 127.0.0.1:1080',
    goagent: 'PROXY 127.0.0.1:8087',
    direct: 'DIRECT'
  };
  domain_groups = {
    company_inner_domain_names: {
      ways: 'direct',
      list: ['t1.com', 'sohuno.com', 'no.sohu.com']
    },
    blocked_by_company: {
      ways: 'aliyun direct',
      list: ['tmall.com', 'amazon.*', 'jd.com', 'paipai.com', 'meituan.com', 'taobao.com', 'appspot.com', '360buy.com']
    },
    blocked_by_gfw: {
      ways: 'shadowsocks direct',
      list: ['angularjs.org', 'getpocket.com', 'dropbox.com', 'fastly.net', 'sf.net', 'sourceforge.net', 'sstatic.net', 'stackoverflow.com', 'wikipedia.org', 'googleapis.com', 'googlevideo.com', 'googlesyndication.com', 'gmail.com', 'mail.google.com', 'plus.google.com', 'googleusercontent.com', 'googlesyndication.com', 'google*.com', 'gstatic.com', 'facebook.com', 'twitter.com', 'youtube.com', 'youtube-nocookie.com', 'atgfw.org', 'blogspot.*']
    }
  };
  match = function(url, domain) {
    return shExpMatch(url, "*://*." + domain + "/*") || shExpMatch(url, "*://" + domain + "/*");
  };
  any = function(iter, f) {
    var x, _i, _len;
    if (f == null) {
      f = function(x) {
        return x;
      };
    }
    for (_i = 0, _len = iter.length; _i < _len; _i++) {
      x = iter[_i];
      if (f(x)) {
        return true;
      }
    }
    return false;
  };
  proxy = function(ways) {
    var proxy_name;
    return ((function() {
      var _i, _len, _ref, _results;
      _ref = ways.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        proxy_name = _ref[_i];
        _results.push(proxys[proxy_name]);
      }
      return _results;
    })()).join('; ');
  };
  return function(url, host) {
    var group, group_name;
    for (group_name in domain_groups) {
      group = domain_groups[group_name];
      if (any(group.list, function(domain) {
        return match(url, domain);
      })) {
        return proxy(group.ways);
      }
    }
    return proxy('direct shadowsocks');
  };
})();
