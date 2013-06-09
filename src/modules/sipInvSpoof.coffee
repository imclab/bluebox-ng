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
{Shodan} = require "./shodan"
{MaxMind} = require "./maxMind"
{Grammar} = require "../tools/grammar"
fs = require "fs"


# ----------------------- Class ----------------------------------

# This class sends a call to a range of IP addresses. It also allows to
# select at what extension we want to call, or a group of them.
exports.SipInvSpoof =
class SipInvSpoof
	
	oneCall = (target, port, path, srcHost, transport, toExt, fromExt) ->
		# Spoofed IP and port (at SIP layer).
		laddress = srcHost or Utils.randomIP()
		lport = Utils.randomPort()
		
		msgObj = new SipMessage "INVITE", "", target, port, laddress, lport, fromExt, toExt, transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		
		conn = new AsteroidsConn target, port, path, transport, lport
		
		conn.on "newMessage", (stream) ->

		conn.on "error", (error) ->
		
		# A request is sent.
		conn.send msgSend
		Printer.highlight "Calling extension "
		Printer.normal "#{toExt}"
		Printer.highlight " in host "
		Printer.normal "#{target}\n"
		Printer.removeCursor()


	callWithExt = (target, port, path, srcHost, transport, rangeExt, delay, callId) ->
		# Extensions range.
		if (Grammar.extRangeRE.exec rangeExt)
			rangeExtParsed = Parser.parseExtRange rangeExt
			doLoopNum = (i) =>
				setTimeout(=>
					oneCall target, port, path, srcHost, transport, i, callId
					if i < rangeExtParsed.maxExt
						doLoopNum(parseInt(i) + 1)
				,delay);
			doLoopNum rangeExtParsed.minExt
		# File with extensions.
		else
			if (Grammar.fileRE.exec rangeExt)
				fs.readFile rangeExt, (err, data) ->
					if err
						Printer.printError "sipInvSpoof: #{err}"
					else
						extensions = data
						splitData = data.toString().split("\n")
						doLoopString = (i) =>
							setTimeout(=>
								oneCall target, port, path, srcHost, transport, splitData[i], callId
								# Last is always empty -> 2.
								if i < splitData.length - 2
									doLoopString(i + 1)
							,delay);
						doLoopString 0
			else
				oneCall target, port, path, srcHost, transport, rangeExt, callId
				

	@run : (target, port, path, srcHost, transport, rangeExt, delay, callId) ->
		Printer.normal "\n"
		if (Grammar.ipRangeRE.exec target) or (Grammar.ipRangeRE2.exec target)
			initHost = (target.split "-")[0]
			lastHost = (target.split "-")[1]
			netA = (initHost.split ".")[0]
			netB = (initHost.split ".")[1]
			netC = (initHost.split ".")[2]
			netD = (initHost.split ".")[3]
			net = "#{netA}.#{netB}.#{netC}"
			if (Grammar.ipRangeRE.exec target)
				net2D = (lastHost.split ".")[3] or lastHost	
			else
				net2D = lastHost
			doLoop = (i) =>
				setTimeout(=>
					targetI = "#{net}.#{i}"
					callWithExt targetI, port, path, srcHost, transport, rangeExt, delay, callId
					if i < parseInt(net2D)
						doLoop(parseInt(i) + 1)
				,delay);
			doLoop parseInt(netD)
		else
			callWithExt target, port, path, srcHost, transport, rangeExt, delay, callId
