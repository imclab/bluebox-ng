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

request = require "request"
{Printer} = require "./printer"


# ----------------------- Class ----------------------------------

# This class is used to get the external IP address via icanhazip.com.
exports.ExtIp =
class ExtIp

	printExtIp = (ip) ->
		Printer.info "\n\nYour external IP address is: "
		Printer.result "#{ip}\n"


	@get = () ->
		request.get { uri:"http://icanhazip.com/", json: false }, (err, r, body) ->
			if err
				Printer.error "ExtIp: connection problem."
			else
				printExtIp body
