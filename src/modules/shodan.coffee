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

request = require "request"
xml2js = require "xml2js"
{Printer} = require "../tools/printer"


# ----------------------- Class ----------------------------------

# This class includes some functions related with SHODAN Search Engine. 
exports.Shodan =
class Shodan
		
	connected = false
	# Time to wait for a SHODAN API response.
	timeOut = 20000
	

	printVulnsInfo = (info) ->
		Printer.info "\n\nName: "
		Printer.normal info.name
		Printer.info "\nSource: "
		Printer.normal info.source
		Printer.info "\nLink: "
		Printer.normal info.link
		Printer.info "\nID: "
		Printer.result "#{info.id}"


	printTargetInfo = (info) ->
		Printer.info "\n\nServer: "
		Printer.result "#{info.ip}:#{info.port}"
		Printer.normal " (updated: #{info.updated})"
		Printer.info "\nLocation: "
		Printer.normal "#{info.city}, #{info.country_name} (#{info.longitude}, #{info.latitude})"
		Printer.info "\nResponse:\n"
		Printer.normal "#{info.data}"

	
	printHostData = (info) ->
		Printer.info "\n\nHost: "
		Printer.result "#{info.ip}"
		Printer.info "\nCountry: "
		Printer.normal "#{info.country_code}"
		Printer.info "\nCity: "
		Printer.normal "#{info.city}"
		Printer.info "\nPosition: "
		Printer.normal "(#{info.longitude}, #{info.latitude})"
		Printer.info "\nData:\n"
		for info2 in info.data
			Printer.infoHigh "\nPort: "
			Printer.normal "#{info2.port}"
			Printer.infoHigh "\nOrganization: "
			Printer.normal "#{info2.org}"
			Printer.infoHigh "\nBanner:\n"
			Printer.normal "#{info2.banner}\n"


	printPopInfo = (info) ->
		Printer.info "\nTitle: "
		Printer.normal "#{info.title}"
		Printer.info "\nSummary: "
		Printer.normal info.summary[0]._
		tag = info.id.toString()
		queryRE = /\:\/\?q=*/
		query = tag[(tag.search queryRE)+5..]
		Printer.info "\nQuery: "
		Printer.result "\"#{query}\""
		Printer.info "\nLast updated: "
		Printer.normal "#{info.updated}\n"


	callback = () ->
		if not connected
			Printer.error "Connection problem: Can't reach the target or no response"


	# It looks for known vulnerabilities for an specific service version
	@searchVulns = (service, version, key) ->
		setTimeout callback, timeOut
		# We use request library to get a JSON file and parse it
#		console.log "#{baseUrl}search_exploits?q=#{service}+#{version}&key=#{key}"
		request.get { uri:"#{baseUrl}search_exploits?q=#{service}+#{version}&key=#{key}", json: true }, (err, r, body) ->
			connected = true
			if err
				Printer.error "Shodan: connection problem: #{err}"
			else
				if body.error
					Printer.error "Shodan: #{body.error}"
				else
					if body.total isnt 0
						printVulnsInfo info for info in body.matches
					else
						Printer.highlight "\nNo vulns found.\n"


	# It makes a SHODAN API request using an specified query.
	@searchQuery = (query, pages, key) ->
		setTimeout callback, timeOut
#		console.log "#{baseUrl}search?q=#{query}&p=#{pages}&key=#{key}"
		request.get { uri:"#{baseUrl}search?q=#{query}&p=#{pages}&key=#{key}", json: true }, (err, r, body) ->
			connected = true
			if err
				Printer.error "Shodan: connection problem: #{err}"
			else
				if body.error
					Printer.error "Shodan: #{body.error}"
				else
					results = body.matches
					if body.total isnt 0
						printTargetInfo info for info in results when info.city
						Printer.info "\n\nTotal: "
						Printer.result body.total + "\n"
					else
						Printer.highlight "\nNo hosts found :(\n"


	# It search for indexed hosts running specified service version.
	# TODO: add search to found ips in case that be indexed also port 80, 443, or common of pannels
	@searchTargets = (service, version, port, country, pages, key) ->
		query = "#{service}"
		query += "+#{version}" if version
		query += "+port%3A#{port}" if port
		query += "+country%3A#{country}" if country
		@searchQuery query, pages, key


	# It asks for info indexed of one host and print it (if any).
	@searchHost = (ipAddress, key) ->
		setTimeout callback, timeOut
#		console.log "#{baseUrl}host?ip=#{ipAddress}&key=#{key}"
		request.get { uri:"#{baseUrl}host?ip=#{ipAddress}&key=#{key}", json: true }, (err, r, body) ->
			connected = true
			if err
				Printer.error "Shodan: connection problem: #{err}"
			else
				if body.error
					Printer.error "Shodan: #{body.error}"
				else
					printHostData body


	# It uses a SHODAN RSS feed to get latest popular search related with VoIP.
	@searchPopular = () ->
		setTimeout callback, timeOut
		request.get { uri:"#{popularUrl}", json: false }, (err, r, body) ->
			connected = true
			if err
				Printer.error "Shodan: connection problem: #{err}."
			else
				if body.error
					Printer.error "Shodan: #{body.error}"
				else
					parser = new xml2js.Parser().parseString
					parser body, (err, result) ->
						# TODO: IF error
						printPopInfo info for info in result.feed.entry
						
						
	# SHODAN API needed functions still not working!
	@download = (id, key) ->
		console.log "#{baseUrl}exploitdb/download?id=#{id}&key=#{key}"
#		request.get { uri:"#{baseUrl}exploitdb/download?id=#{id}&key=#{key}", json: false }, (err, r, body) ->


# Needed URLs.
baseUrl = "http://www.shodanhq.com/api/"
popularUrl = "http://www.shodanhq.com/browse/tag/voip?feed=1"
