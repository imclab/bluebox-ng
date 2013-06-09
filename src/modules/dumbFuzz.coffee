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

{AsteroidsConn} = require "../tools/asteroidsConn.coffee"
{Printer} = require "../tools/printer.coffee"
{Utils} = require "../tools/utils.coffee"


# ----------------------- Class ----------------------------------

# This class implements a really stupid generic fuzzer.
exports.DumbFuzz =
class DumbFuzz

	oneRequest = (target, port, path, transport, payload) ->
		# Spoofed IP and port (at SIP layer).
		lport = Utils.randomPort()
		
		msgSend = (String) payload
		conn = new AsteroidsConn target, port, path, transport, lport
		
		conn.on "newMessage", (stream) ->

		# We are looking only for crashes.
		# TODO: Get info about the crash
		conn.on "error", (error) ->

		# A request is sent.
		conn.send payload


	@run = (target, port, path, transport, fuzzString, fuzzMin, fuzzMax, delay) ->

		payload = ""

		Printer.normal "\n"
		# Loop start with different lenghts (i).
		doLoopNum = (i) =>
			setTimeout(=>
				payload += fuzzString
				Printer.info "Sending payload: "
				Printer.result "#{payload}\n"
				oneRequest target, port, path, transport, payload
				Printer.removeCursor()
				if (i < parseInt(fuzzMax))
					doLoopNum(i + 1)
			,delay);
		doLoopNum parseInt(fuzzMin)
