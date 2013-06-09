###

Copyright (C) 2013, Jesus Perez <jesusprubio gmail com>

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

###


# ----------------------- Class ----------------------------------

# This class includes all regular expressions.
exports.Grammar =
class Grammar
	
	# IP address.	
	@ipRE = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
	
	
	# IP address range. (ie: 192.168.122.1-192.168.122.254)
	@ipRangeRE = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})-(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/


	# IP address range. ( ie: 192.168.122.1-254) 
	@ipRangeRE2 = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})-(\d{1,3})/

		
	# Service version.
	@versionRE = /(\d{1,2}(\.\d{1,2})?(\.\d{1,2}})?)/

	
	# Service port.
	@portRE = /\d{2,5}/

	
	# IP address range. ( ie: 192.168.122.1-254) 
	@portRangeRE = /(\d{1,5})-(\d{1,5})/


	# Extension.
	@extRE = /\d{1,10}/

	# Extension range.
	@extRangeRE = /\d{1,10}-\d{1,10}/

		
	# "User-Agent:" string.
	@userRE = /User\-Agent\:/i

	
	# "Server:" string.
	@serverRE = /Server\:/i	

	
	# "Organization:" string.
	@orgRE = /Organization\:/i


	# "SIP 2.0" string.
	@codeLineRE = /SIP\/2.0/

	
	# SIP response code number.
	@codeRE = /\d{3}/

	
	# Text file path.
	@fileRE = /\.txt/


	# "Organization:" string.
	@authRE = /WWW-Authenticate\:/i

	
	# "Organization:" string.
	@authProxyRE = /Proxy-Authenticate\:/i


	# "realm" string.
	@realmRE = /realm/i

	
	# "nonce" string.
	@nonceRE = /nonce/i
	
	
	# "nonce" string.
	@httpRE = /http:\/\//
