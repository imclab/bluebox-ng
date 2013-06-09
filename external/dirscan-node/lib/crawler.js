/*
	Crawling Engine
	@sha0coder
*/

var web = require('./web.js');
var furl = require('./url.js');

crawler = {
	href: /href *= *["']([^"']+)["']/g,
};

crawler.pathParts = function(url,path,isDirListing) {	
	//TODO: should be local function
	if (path == '/')
	    return;

	url = furl.fixUrl(url);

	var p = path.split('/');          
	for (var i=1; i<p.length; i++) {
	    x = '';
	    for (var j=0; j<i; j++)
			x += p[j]+'/'

			if (x != '/') {
			    var newUrl = furl.fixUrl(url) + furl.fixDir(x);

			    //console.log('-->'+x);
			    eater.push(newUrl,true);
			    if (!isDirListing && furl.isDir(x)) 
		        	scan.dirGet(newUrl);
			}
	}
};

crawler.crawl = function(url,html,isDirListing) {
	var dir = '';

	while (dir = crawler.href.exec(html)) {

	    if (dir[1].substring(0,1) == '?' || dir[1].substring(0,7) == 'mailto:' || dir[1] == '/') 
	    	continue;

	    //URL href="http://xxx.com/lala"
	    if (dir[1].substring(0,4) == 'http') {
			if (furl.getDomain(dir[1]) == furl.getDomain(url)) 
			    eater.push(dir[1],true);


	    //ABSOLUTE PATH  href="/lala/lalo"
	    } else if (dir[1].substring(0,1) == '/') {
			var showurl = furl.fixUrl(furl.getBase(url)+dir[1]);

		    eater.push(showurl,true); //DUPLICATED PUSH? with pathparts
		    crawler.pathParts(furl.getBase(url),dir[1],isDirListing);


	    //RELATIVE PATH href="file.png" o href="lala/lalo/"
	    } else {
	          
			//last dir of the url
			//url = url.replace(/\/[^\/]+$/,'/').replace(/\x0d/,'%0d'); //TODO: quitar estos replaces
			//dir[1] = dir[1].replace(/\x0d/,'%0d');

			var showurl = furl.getUrlDir(url)+dir[1]; //furl.fixUrl(url+dir[1]);
		    eater.push(showurl,true); //DUPLICATED PUSH? with pathparts
		    crawler.pathParts(furl.getUrlDir(url),dir[1],isDirListing);
	    }
	}
};

exports.crawler = crawler;