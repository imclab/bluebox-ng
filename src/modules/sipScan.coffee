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

# ----------------------- Class ----------------------------------

# This class includes one function which  sends a valid SIP request and parse 
# the response looking for a string with "User-Agent:", "Server:" or 
# "Organization" to get info about the SIP service which running on the target.
exports.SipScan =
class SipScan

	printScanInfo = (info) ->
		Printer.infoHigh "\n\nFINGERPRINT =>\n"
		Printer.info "\nService: "
		Printer.result info.service
		Printer.info "\nVersion: "
		Printer.result info.version
		Printer.info "\nMessage:\n"
		Printer.normal info.message
		

	printScanInfoLite = (info, target) ->
		# TODO: Print info about actual target like in other modules
		Printer.info "\nIP address: "
		Printer.result target
		Printer.info ", Service: "
		Printer.result info.service
		Printer.info ", Version: "
		Printer.result info.version
		Printer.info "\nMessage:\n"
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
			Printer.error error if not isRange
			
		# A request is sent.
		conn.send msgSend


	@run = (target, port, path, srcHost, transport, type, shodanKey, delay) ->

		# IP range.
		# ie: 192.168.122.1-254, ::::::1-ffff
		if /-/.exec target
			splittedTarget = (target.split "-") 
			initHost = splittedTarget[0]
			lastBlock = splittedTarget[1]
			# If IPv6 we need the long form.

			# IPv4 vs IPv6
			if (/:/.test initHost)
				initHost = Utils.normalize6 initHost
				blockSeparator = ":"
				raddix = 16
			else
				blockSeparator = "."
				raddix = 10

			splittedHost = initHost.split "#{blockSeparator}"
			netBlocks = splittedHost[0..(splittedHost.length-2)].join "#{blockSeparator}"
			firstBlock = splittedHost[splittedHost.length-1]
			doLoop = (i) =>
				setTimeout(=>
					targetI = "#{netBlocks}#{blockSeparator}#{i.toString(raddix)}"
					console.log targetI
					oneScan targetI, port, path, srcHost, transport, type, shodanKey, true
					if (parseInt(i, 10) < parseInt(lastBlock, raddix))
						doLoop(parseInt(i,10) + 1)
				,delay);
			doLoop parseInt(firstBlock, raddix)
			# TODO: Add files support. (with port)
			# TODO: Change in the rest of the files parseInt to use 10 as raddix
			# TODO: Add port range
		else
			# Needed to work with Node module net.isIPv6 function.
			if (/:/.test target)
				target = Utils.normalize6 target
			oneScan target, port, path, srcHost, transport, type, shodanKey, false