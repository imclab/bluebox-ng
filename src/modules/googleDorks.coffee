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

fs = require "fs"
{Printer} = require "../tools/printer"


# ----------------------- Class ----------------------------------

# This class gets JSON file with some Google dorks, parse and print it.
exports.GoogleDorks =
class GoogleDorks

	printDork = (dork) ->
		Printer.info "\nName: "
		Printer.normal dork.name
		Printer.info "\nDorks:\n"
		for i in dork.dorks
			Printer.result "#{i}\n"


	@print = () ->
		fs.readFile "./data/googleDorks.json", (err, data) ->
			if err
				Printer.error "Dorks: #{err}"
			else
				Printer.normal "\n"			
				jsonData = JSON.parse data
				for i in jsonData
					printDork i
