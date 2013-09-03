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

#evilscan = require "evilscan"
{BashCommand} = require "./bashCommand"
#{Printer} = require "../tools/printer"


# ----------------------- Class ----------------------------------

# This module implements an Evilscan wrapper.
exports.NetworkScan =
class NetworkScan

	# printInfo = (info) ->
    
    # TODO: There is an error in the npm. Opened issue:
    # https://github.com/eviltik/evilscan/issues/29
#	@run = (target, port) ->
#		options =
#			target: "192.168.122.59"
#			port: "22, 5060"
#			status: "TROU" # Timeout, Refused, Open, Unreachable
#			banner: true
#
#		scanner = new evilscan(options)
#		scanner.on "result", (data) ->
#			# fired when item is matching options
#			console.log data
#
#		scanner.on "error", (err) ->
#			throw new Error(data.toString())
#
#		scanner.on "done", ->
#			console.log "done"
#
#		scanner.run()
    
    # Temp real ugly (because we can't use npm events) trick, run as external command.
    @run = (target, port) ->
        BashCommand.run "node node_modules/evilscan/bin/evilscan.js #{target} --port=#{port} --status=RO --banner"