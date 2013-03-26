Bluebox-ng
==========

Bluebox-ng is a next generation UC/VoIP security tool. It has been written in CoffeeScript using Node.js powers. This project is "our 2 cents" to help to improve information security practices in VoIP/UC environments.

- GitHub repo: [https://github.com/jesusprubio/bluebox-ng](https://github.com/jesusprubio/bluebox-ng)
- Demo: TODOOOOOOOO
[[youtube-{02AuYf66sx0}-{688}x{387}]]


Install deps
------------
* cd bluebox-ng
* npm install


Run:
----
* npm start


Features:
---------
* Automatic pentesting process (VoIP, web and service vulns)
* SIP (RFC 3261) and extensions compliant
* TLS and IPv6 support
* VoIP DNS SRV register support
* SIP over websockets (and WSS) support (draft-ietf-sipcore-sip-websocket-08)
* REGISTER, OPTIONS, INVITE, MESSAGE, SUBSCRIBE, PUBLISH, OK, ACK, CANCEL, BYE, Ringing and Busy Here requests support
* Extension and password brute-force through different methods (REGISTER, INVITE, SUBSCRIBE, PUBLISH, etc.)
* DNS SRV registers discovery
* SHODAN and Google Dorks
* SIP common vulns modules: scan, extension brute-force, Asterisk extension brute-force (CVE-2011-4597), invite attack, call all LAN endpoints, invite spoofing, registering hijacking, unregistering, bye teardown
* SIP DoS/DDoS audit
* SIP dumb fuzzer
* Common VoIP servers web management panels discovery and brute-force
* Automatic exploit searching (Exploit DB, PacketStorm, Metasploit)
* Automatic vulnerability searching (CVE, OSVDB)
* Geolocalization using WPS (Wifi Positioning System) or IP address (Maxmind database)
* Colored output
* Command completion


Roadmap:
--------
* Tor support
* More SIP modules 
* SIP Smart fuzzing (SIP Torture RFC)
* Eavesdropping
* CouchDB support (sessions)
* H.323 support
* IAX support
* Web common panels post-explotation (Pepelux research)
* A bit of command Kung Fu post-explotation
* RTP fuzzing
* Advanced SIP fuzzing with Peach
* Reports generation
* Graphical user interface
* Windows support
* Include it in Debian
* Include it in Kali GNU/Linux
* Team/multi-user support
* Documentation
* ...
* Any suggestion/piece of code ;) is appreciated.


Author
------
- Jesús Pérez
* [@jesusprubio](https://twitter.com/jesusprubio)
* jesusprubio gmail com
* [http://nicerosniunos.blogspot.com/] (http://nicerosniunos.blogspot.com/)


Contributors
------------
- Damián Franco
* [@pamojarpan](https://twitter.com/pamojarpan)
* pamojarpan google com

- Jose Luis Verdeguer
* [@pepeluxx](https://twitter.com/pepeluxx)
* pepelux enye-sec org
* [http://www.pepelux.org/](http://www.pepelux.org/)


Thanks to ...
-------------
* [Quobis](http://www.quobis.com), some hours of work through personal projects program
* Antón Román ([@antonroman](https://twitter.com/antonroman)), he speaks SIP and I'm starting to speak it thanks to him
* Sandro Gauci ([@sandrogauci](https://twitter.com/sandrogauci)), SIPVicious was our inspiration
* Kamailio community ([@kamailioproject](https://twitter.com/kamailioproject)), my favourite SIP Server
* David Endler and Mark Collier ([@markcollier46](https://twitter.com/markcollier46)), authors of "Hacking VoIP Exposed" book
(http://www.hackingvoip.com/)
* John Matherly ([@achillean](https://twitter.com/achillean)) for SHODAN API and GHDB
* All VoIP, free software and security hackers that we read everyday


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
