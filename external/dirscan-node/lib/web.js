// @sha0coder

var http = require('http');
var https = require('https');

web = {};

web.isHttps = function(url) {
	return (url.substring(0,5) == 'https');
}

web.getPort = function(url, opts) {
	var domain = url.split('/')[2];
	if (domain.search(':') >= 0) {
		opts.host = domain.split(':')[0];
		opts.port = domain.split(':')[1];
	}
}

web.get = function(url,cb,errcb) {
	var h = http;

	var opts = {
		host: url.split('/')[2],
		port: 80, 
		method: 'GET',
		path: url.replace(/^https?:?\/\/[^\/]+/,''),
		rejectUnauthorized: true,
		headers: {
			'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; rv:20.0) Gecko/20100101 Firefox/20.0'
		}
	};

	if (web.isHttps(url)) {
		h = https;
		opts.port = 443;
	}

	web.getPort(url,opts);

	h.get(opts, function(res) {
		res.setEncoding('utf8');
		var data = '';

		res.on('data',function(chunk) {
			data += chunk;
		});
		res.on('end',function() {
			cb(url,data,res);
		});
	}).on('error',function(err) {
		if (errcb)
			errcb(url,err);
	});
};

web.post = function(url,data,cb,errcb) {
	var h = http;
	var opts = {
		host: url.split('/')[2],
		port: 80, //TODO PARSE :port IN URL
		method: 'POST',
		path: url.replace(/^https?:?\/\/[^\/]+/,''),
		rejectUnauthorized: true,

		headers: {
			'Content-Type': 'application/x-www-form-urlencoded',
			'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; rv:20.0) Gecko/20100101 Firefox/20.0',
			'Content-Length': data.length
    	}
	};

	if (web.isHttps(url)) {
		h = https;
		opts.port = 443;
	}

	web.getPort(url,opts);

	var req = h.request(opts, function(res) {
		var data = '';


		res.on('data',function(chunk) {
			data += chunk;
		});

		res.on('end',function() {
			cb(url,data,res);
		});
	});

	req.on('error', function() {
		if (errcb)
			errcb();
	});

	req.write(data);
	req.end();

}


exports.get = web.get;
exports.post = web.post;
exports.isHttps = web.isHttps;