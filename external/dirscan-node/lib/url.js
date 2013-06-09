/*
      url utils
      @sha0coder
*/

exports.getUrlDir = function(url) {
      return url.replace(/\/[^\/]*$/,'/')
}

exports.getBase = function(url) {
      var spl = url.split('/');

      return spl[0]+'//'+spl[2];
};

exports.getDomain = function(url) {
      return url.split('/')[2];
};

exports.isDir = function(url) {
      return (url.charAt(url.length-1) == '/')
};

exports.isDirListing = function(html) {
      return (html.search('<title>Index of /') > 0);
};

exports.fixUrl = function(url) {
      url = url.replace(/\x0d/,'%0d').replace('/./','/'); //.replace(/\/\/$/,'/');
      if (url.charAt(0)!='h')
            url = 'http://'+url;
      if (url.charAt(url.length-1) != '/')
            url = url+'/';
      return url;
};

exports.fixDir = function(dir) {
      if (dir.charAt(0) == '/')
            dir = dir.substring(1,dir.length);
      return dir;
};