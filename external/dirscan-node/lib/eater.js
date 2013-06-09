/*
      url eater, the http processing queue
      @sha0coder
*/

var web = require('./web.js');


Array.prototype.exists = function(search) {
      for (var i=0; i<this.length; i++)
            if (this[i] == search) return true;
            
      return false;
};


eater = {
      debug: false,
      running: false,
      queue: [],
      next: 0,          // moving pointers instead data for more speed and less cpu/ram
 

      run: function() {
            eater.running = true;

            while (eater.next < eater.queue.length) {
                  var a = web.get(eater.queue[eater.next++], scan.parse, scan.timeout);
            }

            eater.running = false;
      },

      push: function(item,urgent) {
            item = item.replace('/./','/').replace(/\/\/$/,'/');

            if (eater.queue.exists(item))
                  return;

            if (urgent) 
                  eater.queue.splice(eater.next,0,item);
            else {
                  eater.queue.push(item);
            }

            if (!eater.running)
                  eater.run();
      },

      debug: function() {
            
      }

};

exports.eater = eater;