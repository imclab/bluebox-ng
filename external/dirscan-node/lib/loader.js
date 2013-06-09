var reader = require('line-reader');

exports.load = function(file, url) {
	reader.eachLine(file, function(word,last) {
	    scan.wordlist.push(word);

	    scan.ext.forEach(function(ext) {
	    	eater.push(url+word+ext);
	    });

	});
};