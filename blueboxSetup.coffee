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

readline = require "readline"
fs = require "fs"
wget = require "wget"
{exec} = require "child_process"
{Printer} = require "./src/tools/printer"
{Utils} = require "./src/tools/utils"


# --------------------- Functions --------------------------------

# It prints informational message launched when configuration finishes.
printFinish = () ->
	Printer.info "Initial setup finished, run "
	Printer.result "\"./bluebox.sh\""
	Printer.info " to start.\n\n"
		
run = () ->
	# Restart options.json file (just in case)
	exec "cp options.json.example options.json", (err, stdout, stderr) ->
		if err
			Printer.error stderr
		else
			# Change firstTime to "no"
			Utils.changeJsonTime()
			printFinish()	

# It reads options.json file and if everything is fine main code is executed.
# It print init informational message.
Printer.welcome()
run()