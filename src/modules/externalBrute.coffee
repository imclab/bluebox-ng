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

{Printer} = require "../tools/printer.coffee"
{Utils} = require "../tools/utils.coffee"
{Grammar} = require "../tools/grammar"
{EventEmitter} = require "events"
fs = require "fs"


# ----------------------- Class ----------------------------------

# This class includes do auth brute-force to non SIP protocols such as 
# Asterisk AMI, SSH, MYSQL, etc. They are often present in VoIP environments
# and some Node modules which implement it are already available.
exports.ExternalBrute =
class ExternalBrute extends EventEmitter

	@emitter = new EventEmitter
	# Time to wait for a response.
	timeOut = 2000
	
	printBrutePass = (user, pass) ->
		Printer.info "\nPassword found (user "
		Printer.infoHigh "#{user}"
		Printer.info "): "
		Printer.result "#{pass}\n"

	oneBrute = (target, port, testUser, testPass, type) ->
        isValid = true
        isConnected = false

        callback = () =>
            if (isValid and isConnected)
                printBrutePass testUser, testPass

        setTimeout callback, timeOut
        ami = require("asterisk-manager")(port, target, testUser, testPass, true)
        
        # Listen for specific AMI events.
        ami.on "end", (evt) ->
            isValid = false
            Printer.highlight "Last tested combination "
            Printer.normal "\"#{testUser}\"/\"#{testPass}\"\n"
            Printer.removeCursor()

        ami.on "connect", () ->
        	isConnected = true
            
        ami.on "error", (evt) ->
        	isValid = false
        	Printer.error "ExternalBrute: Connection problem: #{evt}"
            
            
	brute = (target, port, testUser, passwords, delay, type) =>
		# File with passwords is provided.
		if (Grammar.fileRE.exec passwords)
			fs.readFile passwords, (err, data) =>
				if err
					Printer.error "ExternalBrute: readFile(): #{err}"
				else
					splitData = data.toString().split("\n")
					doLoopString = (i) =>
						setTimeout(=>
							oneBrute target, port, testUser, splitData[i], type
							if i < splitData.length - 1
								doLoopString(parseInt(i, 10) + 1)
							else
								@emitter.emit "passBlockEnd", "Block of passwords ended"
						,delay);
					doLoopString 0
		# Single password is provided.
		else
			oneBrute target, port, testUser, passwords, type
			@emitter.emit "passBlockEnd", "Block of passwords ended"


	@run = (target, port, userList, delay, passwords, type) ->
		Printer.normal "\n"
		# TODO: Test if the module supports IPv6
		if (/:/.test target)
			target = Utils.normalize6 target
		# File with users.
		if (Grammar.fileRE.exec userList)
			fs.readFile userList, (err, data) =>
				if err
					Printer.error "amiBrute: readFile(): #{err}"
				else
					i = 0
					splitData = data.toString().split("\n")
					@emitter.on "passBlockEnd", (msg) ->
						if i < splitData.length - 1
							i += 1
							brute target, port, splitData[i], passwords, delay, type

					# First request
					brute target, port, splitData[i], passwords, delay, type
		# Unique extension.
		else
			brute target, port, userList, passwords, delay, type