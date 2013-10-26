![bluebox-ng](https://dl.dropboxusercontent.com/s/fvnxjolk0wjza9v/Bluebox_logo.svg?dl=1&token_hash=AAFbFGTrXirXj4eFSkToscXgnP3k_boZ8SGDqJQ0R-2Elg)

Bluebox-ng
==========
Bluebox-ng is a GPL VoIP/UC vulnerability scanner. It has been written in CoffeeScript using Node.js powers. This project is "our 2 cents" to help to improve information security practices in this kind of environments.

- **GitHub repo**: [https://github.com/jesusprubio/bluebox-ng](https://github.com/jesusprubio/bluebox-ng)
- **IRC(Freenode)**: #breakingVoIP

Install
-------
**GNU/Linux and Mac OS X**
- Install Node.js:
 - Linux: [https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)
 - Mac: [http://nodejs.org/download/](http://nodejs.org/download/)

**Windows**
- Install Node.js: [http://nodejs.org/download/](http://nodejs.org/download/)
- Install Gow (the lightweight alternative to Cygwin): [https://github.com/bmatzelle/gow/wiki](https://github.com/bmatzelle/gow/wiki)

**All**
- *git clone https://github.com/jesusprubio/bluebox-ng/*
- *cd bluebox-ng*
- *chmod +x setup.sh* (just in case)
- *setup.sh*
- *bluebox.sh*


Issues
------
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
- Authentication and extension brute-forcing through different types of requests
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


Actual modules
--------------
- *shodan-search*: Find potential targets in SHODAN computer search engine.
- *shodan-pop*: Quick access to popular SHODAN VoIP related queries.
- *google-dorks: Find potential targets using a Google dork.
- *sip-dns*: DNS SRV and NAPTR discovery.
- *sip-scan*: A SIP host/port scanning tool.
- *sip-brute-ext*: Try to brute-force valid extensions of the SIP server using REGISTER (CVE-2011-2536) or INVITE (no CVE, [http://goo.gl/8LRh6s](http://goo.gl/8LRh6s)) requests.
- *sip-brute-ext-nat*: Try to brute-force valid extensions in Asterisk using different NAT settings (CVE-2011-4597).
- *sip-brute-pass*: Try to brute-force the password for an extension.
- *sip-unauth*: Try know if a SIP server allows unauthenticated calls.
- *sip-unreg*: Try to unregister another endpoint.
- *sip-bye*: Use BYE teardown to end an active call.
- *sip-flood*: Denial of service (DoS) protection mechanism stress test.
- *dumb-fuzz*: Really stupid fuzzer.
- *ami-brute*: Try to brute-force valid credentials for Asterisk AMI service.
- *db-brute*: Try to brute-force valid credentials for a DB (MySQL/MongoDB).
- *ssh-brute*: Try to brute-force valid credentials for a SSH server.
- *sftp-brute*: Try to brute-force valid credentials for a FTP/SFTP server.
- *tftp-brute*: Try to brute-force a valid file for a TFTP server.
- *ldap-brute*: Try to brute-force valid credentials for a LDAP/Active Directory server.
- *http-brute*: Try to brute-force valid credentials for an HTTP server.
- *http-discover*: Discover common web panel of a VoIP servers in a host (Dirscan-node).
- *network-scan*: Host/port scanning (Evilscan).
- *shodan-host*: Get indexed info of an IP address in SHODAN.
- *shodan-vulns*': Find vulnerabilities and exploit for an specifig service version (using SHODAN API).
- *shodan-query*: Use a customized SHODAN VoIP query.
- *shodan-download*: Download an exploit.
- *search-vulns*: Find vulnerabilities and exploit for an specifig service version (using exploitsearch.net API).
- *default-pass*: Show common VoIP system default passwords.
- *geo-locate*: Geolozalization (Maxmind DB).
- *get-ext-ip*: Get you external IP address (icanhazip.com).


Developer guide
---------------
- To contribute we use [GitHub pull requests](https://help.github.com/articles/using-pull-requests).
- Only include external tools written in Node.js
- Styleguide:
 - Always use camelCase, never underscores
 - Use soft-tabs with a four space indent
 - Follow the style of the actual modules


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
