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

{Printer} = require "../tools/printer.coffee"
{BashCommand} = require "./bashCommand"


# ----------------------- Class ----------------------------------

# This class uses dirscan-node tool to brute-force web directories.
exports.HttpDiscover =
class HttpDiscover

	@run = (url, type) ->
		basePath = "external/dirscan-node/wordlists/"
		if type is "quick"
			file = "#{basePath}dirs.txt"
		else
            file = "#{basePath}big.txt"
        
        BashCommand.run "node external/dirscan-node/dirscan.js #{url} #{file} \'.php,.cfg,.conf,.sql,.log,.txt,.tar,.zip,.gz,.bz2,.tar.gz,.tar.bz2\'"