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
		# Spoofed IP and port (at SIP layer).
		laddress = srcHost or Utils.randomIP()
		lport = Utils.randomPort()
		fromExt = Utils.uniqueId 3
		toExt = Utils.uniqueId 3

		msgObj = new SipMessage type, "", target, port, laddress, lport, fromExt, toExt, transport, "", "", "", false, "", "", "", "", "", ""
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
			Printer.printError error if not isRange
			
		# A request is sent.
		conn.send msgSend


	@run = (target, port, path, srcHost, transport, type, shodanKey, delay) ->
		
		if (Grammar.ipRangeRE.exec target) or (Grammar.ipRangeRE2.exec target)
			initHost = (target.split "-")[0]
			lastHost = (target.split "-")[1]
			netA = (initHost.split ".")[0]
			netB = (initHost.split ".")[1]
			netC = (initHost.split ".")[2]
			netD = (initHost.split ".")[3]
			net = "#{netA}.#{netB}.#{netC}"			
			if (Grammar.ipRangeRE.exec target)
				net2D = (lastHost.split ".")[3] or lastHost	
			else
				net2D = lastHost
			doLoop = (i) =>
				setTimeout(=>
					targetI = "#{net}.#{i}"
					oneScan targetI, port, path, srcHost, transport, type, shodanKey, true
					if i < parseInt(net2D)
						doLoop(parseInt(i) + 1)
				,delay);
			doLoop parseInt(netD)
		else
			oneScan target, port, path, srcHost, transport, type, shodanKey, false
