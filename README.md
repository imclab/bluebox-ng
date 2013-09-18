Bluebox-ng
==========
Bluebox-ng is an open-source VoIP/UC vulnerability scanner. It has been written in CoffeeScript using Node.js powers. This project is "our 2 cents" to help to improve information security practices in this kind of environments.

- **GitHub repo**: [https://github.com/jesusprubio/bluebox-ng](https://github.com/jesusprubio/bluebox-ng)
- **IRC(Freenode)**: #breakingVoIP

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


Issues
------------
- This is an Beta version, so some know bugs are described here: [https://github.com/jesusprubio/bluebox-ng/issues](https://github.com/jesusprubio/bluebox-ng/issues)
- If you have doubts playing with the software, please use this GitHub section labeling the issue as "question"


Features
--------
- Auto VoIP/UC penetration test (Coming soon)
- RFC compliant
- TLS and IPv6 support
- SIP over websockets (and WSS) support (draft-ietf-sipcore-sip-websocket-08)
- SHODAN, exploitsearch.net and Google Dorks
- SIP common security tools (scan, extension/password bruteforce, etc.)
- REGISTER, OPTIONS, INVITE, MESSAGE, SUBSCRIBE, PUBLISH, OK, ACK, CANCEL, BYE and Ringing requests support
- Authentication through different types of requests
- SIP denial of service (DoS) testing
- SRV and NAPTR discovery
- Dumb fuzzing
- Common VoIP servers web management panels discovery
- Automatic exploit searching (Exploit DB, PacketStorm, Metasploit)
- Automatic vulnerability searching (CVE, OSVDB, NVD)
- Geolocation
- Colored output
- Command completion
- It runs in GNU/Linux, Mac OS X and Windows
- Other common protocols brute-force: Asterisk AMI, MySQL, MongoDB, SSH, (S)FTP, HTTP(S), TFTP, LDAP


Developer guide
---------------
- To contribute we use [GitHub pull requests](https://help.github.com/articles/using-pull-requests).
- Only include external tools written in Node.js
- Styleguide:
 - Always use camelCase, never underscores
 - Use soft-tabs with a four space indent
 - Follow the style of any os the actual modules


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
