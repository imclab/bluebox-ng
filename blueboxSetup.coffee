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
	
printProgress = (progress, infoProg) ->
	per = progress.toString()[2..3]
	Printer.removeCursor()
	Printer.info infoProg
	Printer.normal " #{per}%\n"


# It prints informational message launched when configuration finishes.
printFinish = () ->
	Printer.info "\nInitial setup finished, run "
	Printer.result "\"./bluebox.sh\""
	Printer.info " to start. You can always change the key in "
	Printer.highlight "\"options.json\""
	Printer.info " file or running "
	Printer.highlight "\"./setup.sh\""
	Printer.info " command again.\n"

		
runMenu = () ->
	# Restart options.json file (just in case)
	exec "cp options.json.example options.json", (err, stdout, stderr) ->
		if err
			Printer.error stderr
		else
			# Change firstTime to "no"
			Utils.changeJsonTime()
			# Command line interpreter started (readline).
			rl = readline.createInterface process.stdin, process.stdout
			
			# On Ctrl+C, Ctrl+D, etc.
			rl.on "close", () ->
				Utils.quit()
		
			Printer.info "This is the first run, so we need to do"
			Printer.highlight " some tasks"
			Printer.info " before start to play\n\n"
			
			Printer.infoHigh ">> First of all I need your SHODAN API key,\n"
			Printer.infoHigh ">> you can get it here: "
			Printer.normal "http://www.shodanhq.com/api_doc:\n"
			rl.question "* SHODAN Key: ", (answer) ->
				shodanKey = answer
				if shodanKey is ""
					Printer.error "SHODAN key is null\n"
					Utils.quit()
				else
					Utils.changeJsonKey shodanKey
					Printer.info " - Key " 
					Printer.highlight "\"#{shodanKey}\""
					Printer.info " added\n"
					Printer.infoHigh "\n>> Finally, I need to download two files to geolocate the devices (optional):\n"
					rl.question "* Dou you want to download them? (yes): ", (answer) ->
						answer = "yes" if answer is ""
						if answer in ["yes","no"]
							if answer is "yes"
								# Delete old files (just in case).
								exec "rm -f node_modules/geoip-lite/data/geoip-city.dat; rm -f node_modules/geoip-lite/data/geoip-city-names.dat", (err, stdout, stderr) ->
									if err
										Printer.error err
									else
										src = 'https://dl.dropboxusercontent.com/s/fo27e1xdvva811w/geoip-city.dat?token_hash=AAGXLwgAHJ7WaRui5KJqJNqOlZaSS3HHvBqytcaQZuHzQA&dl=1'
										output = "node_modules/geoip-lite/data/geoip-city.dat"
										download = wget.download src, output

										download.on "error", (error) ->
											Printer.error "Setup: wget: #{error}"
											Utils.quit()

										Printer.normal "\n"
										infoProg = " - Downloading \"geoip-city.dat\"..."
										download.on "progress", (progress) =>
											printProgress progress, infoProg
											
										download.on "end", (output) =>
											Printer.removeCursor()
											Printer.info infoProg
											Printer.highlight " done\n\n"
											src2 = "https://dl.dropboxusercontent.com/s/h19n6ouhudfrdb2/geoip-city-names.dat?token_hash=AAG00buej9Uhhv-s4_5UcCJEMFvksxwDfNgt6siUkSklig&dl=1"
											output2 = "node_modules/geoip-lite/data/geoip-city-names.dat"
											download2 = wget.download src2, output2

											download2.on "error", (error) ->
												Printer.error "Setup: wget: #{error}"
												Utils.quit()

											infoProg2 = " - Downloading \"geoip-city-names.dat\"..."									
											download2.on "progress", (progress2) =>
												printProgress progress2, infoProg2
											
											download2.on "end", (output) =>
												Printer.removeCursor()
												Printer.info infoProg2
												Printer.highlight " done\n"
												printFinish()
												Utils.quit()
							# Answer "no" to download files
							else
								printFinish()
								Utils.quit()
						else
							Printer.error "Bad answer"
							Utils.quit()


# ------------------------ Main ----------------------------------

# It reads options.json file and if everything is fine main code is executed.
# It print init informational message.
Printer.welcome()
shodanKey = ""
fs.readFile "./options.json", (err, data) ->
	if err
		Printer.error "Reading options.json file: #{err}"
	else
		runMenu()
