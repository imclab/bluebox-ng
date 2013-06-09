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
fs = require "fs"


# ----------------------- Class ----------------------------------

# This class includes one function which  sends a valid SIP request and parse 
# the response looking for a string with "User-Agent:", "Server:" or 
# "Organization" to get info about the SIP service which running on the target.
exports.SipBruteExt =
class SipBruteExt

	printIsVuln = (isVuln) ->
		if isVuln
			Printer.highlight "\nThe target could be vulnerable to this vector\n"
		else
			Printer.highlight "\nThe target seems NOT to be vulnerable to this vector\n"


	# It gets the fingerprint and print it with the rest of the outpupt.
	parseReply = (msg, testExt) ->
		# Response parsing.
		code = Parser.parseCode msg
		switch code
			when "401", "407"
				Printer.printEnum testExt, "Auth"
			when "200"
				Printer.printEnum testExt, "Open"
			else
				Printer.highlight "Last tested extension "
				Printer.normal "\"#{testExt}\"\n"
				Printer.removeCursor()


	oneEnum = (target, port, path, srcHost, transport, type, testExt) ->
		lport = Utils.randomPort()
		msgObj = new SipMessage type, "", target, port, srcHost, lport, testExt, "", transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
					
		conn.on "newMessage", (stream) ->
			parseReply stream, testExt

		conn.on "error", (error) ->
			Printer.error "SipBruteExt: #{error}"
			
		conn.send msgSend


	@run = (target, port, path, srcHost, transport, type, rangeExt, delay) ->

		# First request to see if the server could be vulnerable.
		# This extension ("olakase") is impossible to exist.
		lport = Utils.randomPort()
		msgObj = new SipMessage type, "", target, port, srcHost, lport, "olakease", "", transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
		conn.send msgSend
		
		conn.on "newMessage", (stream) ->
			code = Parser.parseCode(stream)
			# First request parsing.
			if code in ["401","407"]
				printIsVuln false
			else if code is "404"
				printIsVuln true
				# Extension range.
				if (Grammar.extRangeRE.exec rangeExt)
					rangeExtParsed = Parser.parseExtRange rangeExt
					doLoopNum = (i) =>
						setTimeout(=>
							oneEnum target, port, path, srcHost, transport, type, i
							if i < rangeExtParsed.maxExt
								doLoopNum(parseInt(i) + 1)
						,delay);
					doLoopNum rangeExtParsed.minExt
				# File with extensions.
				else
					if (Grammar.fileRE.exec rangeExt)
						fs.readFile rangeExt, (err, data) ->
							if err
								Printer.error "sipBruteExt: #{err}"
							else
								extensions = data
								splitData = data.toString().split("\n")
								doLoopString = (i) =>
									setTimeout(=>
										oneEnum target, port, path, srcHost, transport, type, splitData[i]
										# Last is always empty -> 2.
										if i < splitData.length - 2
											doLoopString(i + 1)
									,delay);
								doLoopString 0
					else
						oneEnum target, port, path, srcHost, transport, type, rangeExt
						
		conn.on 'error', (error) ->
			Printer.error "SipBruteExt: #{error}"
