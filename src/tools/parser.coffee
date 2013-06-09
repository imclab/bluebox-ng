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


# ---------------------- Requires --------------------------------

undScore = require "underscore"
{Grammar} = require "./grammar"


# ----------------------- Class ----------------------------------

# This class includes all parsers needed for the rest of the tools.
exports.Parser =
class Parser

	# It parses "User-Agent" string from a packet.
	@parseUserAgent = (pkt) ->
		userLine = undScore.filter pkt.toString().split("\r\n"), (line) ->
			Grammar.userRE.test line
		user = userLine.toString().split(":")[1]

	
	# It parses "Server" string from a packet.
	@parseServer = (pkt) ->
		serverLine  = undScore.filter pkt.toString().split("\r\n"), (line) ->
			Grammar.serverRE.test line
		server = serverLine.toString().split(":")[1]

	
	# It parses "Organization" string from a packet.
	@parseOrg = (pkt) ->
		orgLine = undScore.filter pkt.toString().split("\r\n"), (line) ->
			Grammar.orgRE.test line
		org = orgLine.toString().split(":")[1]


	# It parses the service from a string.
	@parseService = (fprint) ->
		match = /fpbx/i.test fprint.toString()
		if match
			service = "FreePBX"
		else
			cutString = fprint.split(" ")
			if cutString[2]
				service = cutString[1]
			else
				cutString = fprint.split("-")
				if cutString[1]
					service = cutString[0]
				else
					cutString = fprint.split("/")
					if cutString[1]
						service = cutString[0]
					else
						service = fprint
		return service


	# It parses the service version from a string.
	@parseVersion = (fprint) ->
		version = (fprint.match Grammar.versionRE)[0]
	
	
	@parseExtRange = (range) ->
		rangeParsed = range.split "-"
		minExt = rangeParsed[0]
		maxExt = rangeParsed[1]
		return {minExt: minExt, maxExt: maxExt}


	# It parses "Organization" string from a packet.
	@parseCode = (pkt) ->
		codeLine = undScore.filter pkt.toString().split("\r\n"), (line) ->
			Grammar.codeLineRE.test line
		code = (codeLine.toString().match Grammar.codeRE)[0]
		
	
	@parseRealmNonce = (pkt) ->
		isProxy = false
		authLine = (String) undScore.filter pkt.toString().split("\r\n"), (line) ->
			Grammar.authRE.test line
		if not authLine
			isProxy = true
			authLine = (String) undScore.filter pkt.toString().split("\r\n"), (line) ->
				Grammar.authProxyRE.test line
		if authLine
			authSplit = ((authLine.split ":")[1].split ",")
			for i in authSplit
				if Grammar.realmRE.test i
					realm = (i.split "=")[1][1...-1]
				if Grammar.nonceRE.test i
					nonce = (i.split "=")[1][1...-1]
			return {realm: realm, nonce: nonce, isProxy: isProxy}
