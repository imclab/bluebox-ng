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


# ----------------------- Class ----------------------------------

# This class tries to guess if the target accepts unauthenticated calls.
exports.SipUnAuth =
class SipUnAuth	

	@run : (target, port, path, srcHost, transport, fromExt, toExt) ->
		# Spoofed IP and port (at SIP layer).
		laddress = srcHost or Utils.randomIP()
		lport = Utils.randomPort()
		msgObj = new SipMessage "INVITE", "", target, port, srcHost, lport, fromExt, toExt, transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		conn = new AsteroidsConn target, port, path, transport, lport
		conn.send msgSend
		
		conn.on "newMessage", (stream) ->
			code = Parser.parseCode(stream)
			switch code
				when "100"
					Printer.result "\nTarget seems to accept unauthenticated calls.\n"
				when "403", "404"
					Printer.highlight "\nTarget seems NOT to accept calls to this destination, but you should add authentication for calling.\n"
				when "401", "407", ""
					Printer.highlight "\nTarget seems NOT to accept unauthenticated calls.\n"
				else
					Printer.highlight "\nUndefined error code: #{code}.\n"
		
		conn.on "error", (error) ->
			Printer.printError "SipUnAuth: #{error}"
