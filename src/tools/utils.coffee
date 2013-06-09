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

undScore = require "underscore"
fs = require "fs"
{Printer} = require "./printer"


# ----------------------- Class ----------------------------------

# This class includes all tools needed for the rest of the app.
exports.Utils =
class Utils
		
	# Random IP address generator.
	@randomIP = () ->
		array = []
		array.push undScore.random 1, 255 for i in [0..3]
		return array.join(".")
	
	
	# Random IP address generator.
	@randomPort = () ->
		undScore.random 1025, 65535


	# Random IP address generator (over 6000).
	@randomPort2 = () ->
		undScore.random 6000, 65535	

	
	# It creates a Base 36 encoded string from a random number.
	@uniqueId = (length=8) ->
		id = ""
		id += Math.random().toString(36).substr(2) while id.length < length
		id.substr 0, length

	
	# It tests if passed object is a number.
	@isNumber = (num) ->
		undScore.isNumber num
		
	
	# It changes SHODAN key in options.json file.
	@changeJsonKey = (shodanKey) ->
		file = "./options.json"
		fs.readFile file, "utf8", (err, fileContents) =>
			if err
				Printer.error "changeJsonKey: #{err}"
				@quit
			else
				optionsFile = fileContents
				newOptionsFile = optionsFile.replace /nokey/, shodanKey
				# Replacing body.jade file
				fs.writeFile file, newOptionsFile, "utf8", (err) =>
					if err
						Printer.error "changeJsonKey: #{err}"
						@quit


	# It changes "firstTime = yes" to "no" in options.js file-
	@changeJsonTime = () ->
		file = "./options.json"
		fs.readFile file, "utf8", (err, fileContents) =>
			if err
				Printer.error "changeJson: #{err}"
				@quit
			else
				optionsFile = fileContents
				newOptionsFile = optionsFile.replace /yes/, "no"
				# Replacing body.jade file
				fs.writeFile file, newOptionsFile, "utf8", (err) =>
				if err
					Printer.error "changeJsonTime: #{err}"
					@quit


	# It closes the app.
	@quit = () ->
		Printer.quit()
		process.exit 0
