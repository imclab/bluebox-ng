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
dns = require "dns"
{Printer} = require "../tools/printer"


# ----------------------- Class ----------------------------------

# This class resolve a domain and get NAPTR and SRV records.
exports.SipDns =
class SipDns

	printLookup = (addresses, family) ->
		Printer.infoHigh "\nLOOKUP =>\n"
		Printer.result "#{addresses}"
		Printer.normal " (IPv#{family})\n\n"


	printNaptr = (info) ->
		Printer.info "Service: "
		Printer.result "#{info.service}\n"
		Printer.info "Replacement: "
		Printer.result "#{info.replacement}\n"
		Printer.info "Order: "
		Printer.normal "#{info.order}\n"
		Printer.info "Preference: "
		Printer.normal "#{info.preference}\n\n"	


	printSrv = (info) ->
		Printer.info "Name: "
		Printer.result "#{info.name}\n"
		Printer.info "Port: "
		Printer.result "#{info.port}\n"
		Printer.info "Priority: "
		Printer.normal "#{info.priority}\n"
		Printer.info "Weight: "
		printer.normal "#{info.weight}\n\n"

		
	@run : (domain) ->

		# Lookup.
		dns.lookup domain, (err, addresses, family) ->
			if err
				if /ENODATA/.test(err)
					Printer.highlight "\nThis domain has no DNS records\n"
				else
					Printer.error "sipDns: #{err}"
			else
				printLookup addresses, family
		
		
		# SRV.
		dns.resolveSrv domain, (err, addresses) ->
			if err
				if /ENODATA/.test(err)
					Printer.highlight "\nThis domain has no SRV records\n"
				else
					Printer.error "sipDns: #{err}"
			else
				for i in addresses
					Printer.infoHigh "\nSRV =>\n"
					printSrv i	


		# NAPTR.
		dns.resolveNaptr domain, (err, addresses) ->
			if err
				if /ENODATA/.test(err)
					Printer.highlight "\nThis domain has no NAPTR records\n"
				else
					Printer.error "sipDns: #{err}"
			else
				Printer.infoHigh "\nNAPTR =>\n"
				for i in addresses
					printNaptr i
