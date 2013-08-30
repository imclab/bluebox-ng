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
{Shodan} = require "./shodan"
{MaxMind} = require "./maxMind"
{Grammar} = require "../tools/grammar"
{EventEmitter} = require "events"
fs = require "fs"

# ----------------------- Class ----------------------------------

# This class includes one function which  sends a valid SIP request and parse 
# the response looking for a string with "User-Agent:", "Server:" or 
# "Organization" to get info about the SIP service which running on the target.
exports.SipScan =
class SipScan extends EventEmitter

	@emitter = new EventEmitter

	printScanInfo = (info) ->
		Printer.infoHigh "\n\nFINGERPRINT =>\n"
		Printer.info "\nService: "
		Printer.result info.service
		Printer.info "\nVersion: "
		Printer.result info.version
		Printer.info "\nMessage:\n"
		Printer.normal info.message
		

	printScanInfoLite = (info, target) ->
		Printer.info "\nIP address: "
		Printer.result target
		Printer.info ", Service: "
		Printer.result info.service
		Printer.info ", Version: "
		Printer.result info.version
		Printer.info ", Message:\n"
		Printer.normal info.message


	printCveDetails = (service) ->
		Printer.infoHigh "\nCVE DETAILS =>\n\n"
		Printer.result 'http://www.cvedetails.com/product-search.php?vendor_id=0&search='+ service + '\n'
	
	
	# It gets the fingerprint and print it with the rest of the outpupt.
	getFingerPrint = (msg) ->
		# Response parsing.
		fingerprint = Parser.parseServer(msg) or Parser.parseUserAgent(msg) or Parser.parseOrg(msg)
		ser = ""
		ver = ""
		if fingerprint
			ser = Parser.parseService fingerprint
			ver = Parser.parseVersion fingerprint
		return {service: ser, version: ver, message: msg}


	oneScan = (target, port, path, srcHost, transport, type, shodanKey, isRange) ->
		lport = Utils.randomPort()

		msgObj = new SipMessage type, "", target, port, srcHost, lport, "", "", transport, "", "", "", false, "", "", "", "", "", ""
		msgSend = (String) msgObj.create()
		
		conn = new AsteroidsConn target, port, path, transport, lport

		conn.on "newMessage", (stream) ->
			output = getFingerPrint stream
			if isRange
				printScanInfoLite(output, target) if output.message
			else
				printScanInfo output if output
				Printer.infoHigh "\nGEOLOCATION =>\n"
				MaxMind.locate target
				if output.service
					printCveDetails output.service
					if shodanKey isnt ""
						Printer.infoHigh "\nVULNERABILITIES AND EXPLOITS =>\n\n"
						Shodan.searchVulns output.service, output.version, shodanKey

		conn.on "error", (error) ->
			# If we're not scanning a range we want to show possible errors.
			Printer.error error if not isRange
			
		# A request is sent.
		conn.send msgSend
		# console.log msgSend
		if isRange
			Printer.highlight "Last tested target "
			Printer.normal "#{target}:#{port}\n"
			Printer.removeCursor()

	# It walks through different ports.
	scan = (target, port, path, srcHost, transport, type, shodanKey, delay, isRange) =>

		# ie: 5000-6000
		if /-/.exec port
			splittedPort = (port.split "-") 
			initPort = splittedPort[0]
			lastPort = splittedPort[1]

			doLoopNum = (i) =>
				setTimeout(=>
					oneScan target, i, path, srcHost, transport, type, "", true
					if parseInt(i, 10) < parseInt(lastPort, 10)
						doLoopNum(parseInt(i, 10) + 1)
					else
						@emitter.emit "portBlockEnd", "Block of ports ended"
				,delay);
			doLoopNum initPort
		else
			# 5060, 5061, 5070
			if /,/.exec port
				# console.log "ENTRA ,"
				portsList = port.split ","
				doLoopString = (i) =>
					setTimeout(=>
						oneScan target, portsList[i], path, srcHost, transport, type, "", true
						if i < portsList.length - 1
							doLoopString(parseInt(i, 10) + 1)
						else
							@emitter.emit "portBlockEnd", "Block of ports ended"
					,delay);
				doLoopString 0
			# Unique port.
			else
				isRange if isRange
				oneScan target, port, path, srcHost, transport, type, shodanKey, isRange
				@emitter.emit "portBlockEnd", "Block of ports ended"



	@run = (target, port, path, srcHost, transport, type, shodanKey, delay) ->

		Printer.normal "\n"
		# IP range.
		# ie: 192.168.122.1-254, ::::::1-ffff
		if /-/.exec target
			splittedTarget = (target.split "-") 
			initHost = splittedTarget[0]
			lastBlock = splittedTarget[1]

			# IPv4 vs IPv6
			if (/:/.test initHost)
				# If IPv6 we need the long form.
				initHost = Utils.normalize6 initHost
				blockSeparator = ":"
				raddix = 16
			else
				blockSeparator = "."
				raddix = 10

			splittedHost = initHost.split "#{blockSeparator}"
			netBlocks = splittedHost[0..(splittedHost.length-2)].join "#{blockSeparator}"

			i = parseInt(splittedHost[splittedHost.length-1], 10)	
			# We need a bit of synchronism to avoid problems with Node.
			@emitter.on "portBlockEnd", (msg) ->
				# Raddix is used to support IPv6 blocks (hex).
				# This delay is needed in case of one (or a few) port,
				# else Node powers saturate the OS ;).
				setTimeout (=>
					if i < parseInt(lastBlock, raddix)
						i += 1
						targetI = "#{netBlocks}#{blockSeparator}#{i.toString(raddix)}"
						scan targetI, port, path, srcHost, transport, type, "", delay, true
				), delay

			# First request
			targetI = "#{netBlocks}#{blockSeparator}#{i.toString(raddix)}"
			scan targetI, port, path, srcHost, transport, type, "", delay, true

		else
			# File with targets.
			if (Grammar.fileRE.exec target)
				fs.readFile target, (err, data) =>
					if err
						Printer.error "sipScan: readFile(): #{err}"
					else
						i = 0
						splitData = data.toString().split("\n")

						@emitter.on "portBlockEnd", (msg) ->
							setTimeout (=>
								if i < (splitData.length - 1)
									i += 1
									scan splitData[i], port, path, srcHost, transport, type, "", delay, true
							), delay

						# First request
						scan splitData[i], port, path, srcHost, transport, type, "", delay. true
			# Unique target.
			else
				# Needed to work with Node module net.isIPv6 function.
				if (/:/.test target)
					target = Utils.normalize6 target
				scan target, port, path, srcHost, transport, type, shodanKey, delay, false