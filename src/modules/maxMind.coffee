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

geoip = require "geoip-lite"
{Printer} = require "../tools/printer"


# ----------------------- Class ----------------------------------

# This class looks for the location of an IP address.
exports.MaxMind =
class MaxMind

	printInfo = (info) ->
		if info
			Printer.info "\nCountry: "
			Printer.normal info.country
			Printer.info "\nRegion: "
			Printer.normal info.region
			Printer.info "\nCity: "
			Printer.normal info.city
			Printer.info "\nLocation: "
			Printer.result "#{info.ll}\n"
		else
			Printer.highlight "\nNo info\n"


	@locate = (target) ->
		geo = geoip.lookup(target)
		printInfo geo
