Bluebox-ng
==========

Bluebox-ng is a next generation UC/VoIP security tool. It has been written in CoffeeScript using Node.js powers. This project is "our 2 cents" to help to improve information security practices in VoIP/UC environments.

- GitHub repo: [https://github.com/jesusprubio/bluebox-ng](https://github.com/jesusprubio/bluebox-ng)
- Demo: [http://www.youtube.com/watch?v=02AuYf66sx0](http://www.youtube.com/watch?v=02AuYf66sx0)


Install node
------------
* sudo apt-get install build-essential python-software-properties libssl-dev git 
* clone https://github.com/joyent/node.git node
* configure
* make
* sudo make install


Get the code (Still unavailable)
------------
* git clone https://github.com/jesusprubio/bluebox-ng


Install deps
------------
* cd bluebox-ng
* npm install


Give permissions
----------------
* chmod a+x bluebox


Run:
----
* ./bluebox
There are two warnings related with WebSocket-Node module. For the moment we prefer do not compile native extensions to avoid compatibility problems. Feel free to compile by yourself following [offical documentation](https://github.com/Worlize/WebSocket-Node).
* Warning: Native modules not compiled.  XOR performance will be degraded.
* Warning: Native modules not compiled.  UTF-8 validation disabled.


Known bugs:
----------
* Too many modules still not implemented.
* IPv6 support not implemented.
* Problem with interpreter and asyncronous requests. If your prompt get lost, just push ENTER.
* Shodan module repeats exploits and vulns. It should be parsed and identified to avoid repeated ones and to automate the process.
* Shodan download is still not implemented in the API. Maybe we should change [SHODAN API](http://docs.shodanhq.com/rest.html) to another solution.
* Geolocation file have to be installed apart, only country if showed if not. To solve it download these two files to folder "node_modules/geoip-lite/data":
- https://github.com/bluesmoon/node-geoip/blob/master/data/geoip-city.dat
- https://github.com/bluesmoon/node-geoip/blob/master/data/geoip-city-names.dat
* If any module which uses "request" gets an error 404 the program chrashes.


Features:
---------
* Automatic pentesting process (VoIP, web and service vulns)
* RFC compliant
* TLS and IPv6 support
* SRV and NAPTR support
* SIP over websockets (and WSS) support (draft-ietf-sipcore-sip-websocket-08)
* REGISTER, OPTIONS, INVITE, MESSAGE, SUBSCRIBE, PUBLISH, OK, ACK, CANCEL, BYE, Ringing and Busy Here requests support
* Extension and password brute-force through different methods (REGISTER, INVITE, SUBSCRIBE, PUBLISH, etc.)
* DNS SRV registers discovery
* SHODAN and Google Dorks
* SIP common security tools
* SIP DoS/DDoS audit
* Dumb fuzzing
* Common VoIP servers web management panels discovery and brute-force
* Automatic exploit searching (Exploit DB, PacketStorm, Metasploit)
* Automatic vulnerability searching (CVE, OSVDB)
* Geolocation
* Colored output
* Command completion


Roadmap:
--------
* Tor support
* More SIP modules
* SIP Smart fuzzing (SIP Torture RFC)
* Eavesdropping
* CouchDB support (sessions)
* IAX support
* Web common panels post-explotation (Pepelux research)
* A bit of command Kung Fu post-explotation
* RTP fuzzing
* Reports generation
* Graphical user interface
* ...
* Any suggestion/piece of code ;) is appreciated.


Author
------
Jesús Pérez
[@jesusprubio](https://twitter.com/jesusprubio)
jesusprubio gmail com
[http://nicerosniunos.blogspot.com/] (http://nicerosniunos.blogspot.com/)


Contributors
------------
Damián Franco
[@pamojarpan](https://twitter.com/pamojarpan)
pamojarpan google com

Jose Luis Verdeguer
[@pepeluxx](https://twitter.com/pepeluxx)
pepelux enye-sec org
[http://www.pepelux.org/](http://www.pepelux.org/)


Thanks to ...
-------------
* [Quobis](http://www.quobis.com), some hours of work through personal projects program
* Antón Román ([@antonroman](https://twitter.com/antonroman)), our SIP mentor
* Sandro Gauci ([@sandrogauci](https://twitter.com/sandrogauci)), SIPVicious was our inspiration
* Kamailio community ([@kamailioproject](https://twitter.com/kamailioproject)), our favourite SIP Server
* David Endler and Mark Collier ([@markcollier46](https://twitter.com/markcollier46)), authors of "Hacking VoIP Exposed" book
(http://www.hackingvoip.com/)
* John Matherly ([@achillean](https://twitter.com/achillean)) for SHODAN API and GHDB
* All VoIP, free software and security hackers that we read everyday
* [Loopsize](https://soundcloud.com/loopsize), a music hacker (and a friend) creator of the themes included in demos


License
-------
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
