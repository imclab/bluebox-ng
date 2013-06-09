#!/usr/bin/env node

/*
      DirScan v0.5
      Web directory scanner, by @sha0coder 
      powered by node.js
*/




var web = require('./lib/web.js');
var furl = require('./lib/url.js');
var loader = require('./lib/loader.js');
var color = require('./lib/color.js').color;
var eater = require('./lib/eater.js').eater;
var crawler = require('./lib/crawler.js').crawler;



scan = {
	ext: [],
	wordlist: [],
      magic: '/l92i029jasdof',
      page404: -1
};


scan.dirGet = function(url) {
      //console.log(' bruteando '+url);
      scan.wordlist.forEach(function(word) {
            scan.ext.forEach(function(ext) {
                  eater.push(url+word+ext);
            });
      });
};


scan.test404 = function(url,cb) {
      web.get(furl.fixUrl(url)+scan.magic, function(url2,data,resp) {

            if (resp.statusCode != 404)
                  scan.page404 = data.length;

            cb();
      }, function(url,err) {
            console.log('site down! '+err);
      });
};


scan.test403 = function(url) {
      // filesystem forbidden or webserver forbidden (on the secon case can be scanned)

      web.get(furl.fixUrl(url)+scan.magic, function(url2,data,resp) {
            if (resp.statusCode == 404) 
                  scan.dirGet(url);
      });
};


scan.parse = function(url,data,resp) {
      var code = resp.statusCode;
      var bytes = 0;

      url = url.replace(/\x0d/,'%0d');

      if (data)
            bytes = data.length;

      if (bytes == scan.page404)
            code = 404;

      switch (code) {
            case 200:
                  if (furl.isDirListing(data)) {
                        console.log('%s[200 Ok DirListing]\t%s%s',color.green[0],url,color.clean);
                        crawler.crawl(url,data,true);

                  } else {
                        console.log('%s[200 Ok] (%d bytes)\t%s%s',color.green[0],bytes,url,color.clean);
                        /*
                        if (scan.isDir(url)) {
                              scan.parsed.push(url);
                              scan.dirGet(url);
                        }*/
                        crawler.crawl(url,data,false);
                  }

                  
                  break;
            case 301:
            case 302:
            case 303:
                  var location = resp.headers['location'];
                  console.log('%s[301 Redirect]\t\t%s\t-->\t%s%s',color.yellow[0],url,location,color.clean);
                  
                  if (location.charAt(0) == '/')
                        eater.push(url+location);

                  else if (location.split('/')[2] == url.split('/')[2])
                        eater.push(location);

                  break;
            case 401:
                  console.log('%s[%d Auth needed]\t%s%s',color.magenta[0],code,url,color.clean);
                  break;
            case 403:
                  console.log('%s[%d DirList denied]\t%s%s',color.yellow[0],code,url,color.clean);

                  /*
                        Hay dos situaciones de 403.
                        1. existe el directorio pero no se puede listar por no tener dir list
                        2. existe el directorio pero no hay permisos

                        test403() detecta cual de las opciones es y solo si es la primera continua escaneando por ahi
                  */
                  scan.test403(url);

                  break;
            case 404:
                  break;
            default:
                  console.log('%s[%d] (%d bytes)\t%s%s',color.blue[0],code,bytes,url,color.clean);
                  break;
      }
};


scan.timeout = function(url) {
      url = url.replace(/\x0d/,'%0d');
      console.log('%s[Timeout!]\t\t%s%s',color.red[1],url,color.clean);
};


scan.run = function(url, file) {
      scan.test404(url, function() {
            eater.push(url);
            loader.load(file, url);
      });
};


scan.main = function() {
      var url,file,ext;

//      if (process.argv.length<5) {
//            console.log('dirscan.js  Web directory scanner, by @sha0coder');
//            console.log('powered by node.js\n');
//            console.log('EXAMPLE:');
//            console.log('  ./dirscan.js http://url.com/ wordlists/dirs.txt \'.php,.cfg,.conf,.sql,.log,.txt,.tar,.zip,.gz,.bz2,.tar.gz,.tar.bz2\'');
//            process.exit();
//      }


      url = furl.fixUrl(process.argv[2]);

      file = process.argv[3];
//      ext = '/,'+process.argv[4];
      ext = '.php,.cfg,.conf,.sql,.log,.txt,.tar,.zip,.gz,.bz2,.tar.gz,.tar.bz2'
      scan.ext = ext.split(',');

      console.log("Scanning ...");
      scan.run(url,file);
};


scan.main();
