Bluebox-ng
==========
Bluebox-ng is a next generation UC/VoIP security tool. It has been written in CoffeeScript using Node.js powers. This project is "our 2 cents" to help to improve information security practices in VoIP/UC environments.

- **GitHub repo**: [https://github.com/jesusprubio/bluebox-ng](https://github.com/jesusprubio/bluebox-ng)


Install
-------
**GNU/Linux and Mac OS X**

- Install Node.js:
 - Linux: [https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)
 - Mac: [http://nodejs.org/download/](http://nodejs.org/download/)
- *cd bluebox-ng*
- *chmod +x setup.sh* (just in case)
- *./setup.sh*
- *./bluebox.sh*

**Windows**

- Install Node.js: [http://nodejs.org/download/](http://nodejs.org/download/)
- Install Gow (the lightweight alternative to Cygwin): [https://github.com/bmatzelle/gow/wiki](https://github.com/bmatzelle/gow/wiki)
- *cd bluebox-ng*
- *chmod +x setup.sh* (just in case)
- *setup.sh*
- *bluebox.sh*

Note: There are two warnings related with WebSocket-Node module. For the moment we prefer do not compile native extensions to avoid compatibility problems. Feel free to compile by yourself following [offical documentation](https://github.com/Worlize/WebSocket-Node).
 - Warning: Native modules not compiled.  XOR performance will be degraded.
 - Warning: Native modules not compiled.  UTF-8 validation disabled.


Known issues
------------
- IPv6 support still not implemented.
- Problem with interpreter and asyncronous requests. If the prompt get lost, just push ENTER.
- SHODAN download is still not implemented in the [API](http://docs.shodanhq.com/rest.html).
- Only a few controls implemented over module parameters.
- Be carefull with the delay that you choose to use between requests. If it were too little Node gets crazy because of its asynchronous nature.
- If any module which uses "request" gets an error 404 the program chrashes.
- About dirscan-node is located in "external" directory for now. We should contribute to the project:
 - Create a npm package to easily include it like the rest of external node tools.
 - Add a wordlist with common VoIP web panels paths.
 - Filter only important info of the response.


Features (Alpha)
----------------
- RFC compliant
- TLS and IPv6 support
- SIP over websockets (and WSS) support (draft-ietf-sipcore-sip-websocket-08)
- SHODAN and Google Dorks
- SIP common security tools (scan, extension/password bruteforce, etc.)
- REGISTER, OPTIONS, INVITE, MESSAGE, SUBSCRIBE, PUBLISH, OK, ACK, CANCEL, BYE and Ringing requests support
- Authentication through different types of requests.
- SIP denial of service (DoS) testing
- SRV and NAPTR discovery
- Dumb fuzzing
- Common VoIP servers web management panels discovery
- Automatic exploit searching (Exploit DB, PacketStorm, Metasploit)
- Automatic vulnerability searching (CVE, OSVDB)
- Geolocation
- Colored output
- Command completion
- It runs in GNU/Linux, Mac OS X and Windows


Roadmap (1.0)
-------------
- Automatic pentesting process (VoIP, web and services)
- Tor support
- SIP DDoS emulation through UDP spoofing
- SIP SQL injection
- SIP Smart fuzzing (SIP Torture RFC)
- DB support for sessions
- IAX support
- Eavesdropping
- TFTP sniffing
- Web common panels post-explotation (Pepelux research)
- A bit of command Kung Fu post-explotation
- Common VoIP servers web management panels discovery and brute-force
- ...
- Any suggestion/piece of code is appreciated ;)


Developer guide
---------------
- To contribute we use [GitHub pull requests](https://help.github.com/articles/using-pull-requests).
- Do not include external tools not written in Node.
- Styleguide:
 - Always use camelCase, never underscores.
 - Use soft-tabs with a four space indent
 - Follow the style of any os the actual modules.


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


Powered by
----------
[![Quobis](http://www.ineo.org/ineo/images/stories/logos/empresasSocias/quobis_logotipo%20actual%20reducido.png)](http://www.quobis.com/)
