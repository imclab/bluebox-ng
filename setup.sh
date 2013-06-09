#! /bin/bash

# Copyright (C) 2013, Jesus Perez <jesusprubio gmail com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# This class configures the app. It was included to make the user happy,
# this way he doesn't need to use Node.js commands.

# Apply permissions (just in case).
chmod +x bluebox.sh
chmod +x external/dirscan-node/dirscan.js

echo "Deleting old node_modules folder ..."
rm -rf node_modules
echo "Installing a new version of them ..."
npm install

# App dependencies are installed and SHODAN key is asked.
node_modules/coffee-script/bin/coffee blueboxSetup.coffee
