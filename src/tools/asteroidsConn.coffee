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

dgram = require "dgram"
net = require "net"
tls = require "tls"
{EventEmitter} = require "events"
WebSocketClient = require("websocket").client


# ----------------------- Class ----------------------------------

# This class implements a connection object which supports UDP, TCP,
# TLS, WS and WSS protocols (IPv4 and IPv6).  
# TODO: IPv6
exports.AsteroidsConn =
class AsteroidsConn extends EventEmitter
	
	constructor : (@target, @port, @path, @transport, @lport) ->
		@connected = false
		# Timeout to print connection errors.
		@timeOut = 10000
		

	send : (message) ->
		
		# This functions is used to show an error if no response is received in 5 seg.
		callback = () =>
			if not @connected
				@emit "error", "Connection problem: Can't reach the target or no response"

		switch @transport
		
			when "UDP"
				@client = dgram.createSocket "udp4"

				@client.on "message", (msg, rinfo) =>
					@emit "newMessage", msg
					@connected = true
					@client.close()

				@client.on "error", (error) ->
					@emit "error", error

				@client.bind @lport
				
				buff = new Buffer message
				setTimeout callback, @timeOut
				@client.send buff, 0, buff.length, @port, @target

			when "TCP", "TLS"
				if @transport is "TCP"
					@client = net.createConnection @port, @target
					setTimeout callback, @timeOut
				else
					setTimeout callback, @timeOut
					@client = tls.connect @port, @target, =>
						@connected = true
						@client.write message
					@client.setEncoding "utf-8"
					# TODO: To get info about the cert
				
				@client.on "data", (data) =>
					@emit "newMessage", data
					@client.destroy()

				if @transport is "TCP"
					@client.on "connect", () =>
						@client.write message
						@connected = true

				@client.on "error", (error) =>
					@emit "error", error
			
			when "WS", "WSS"
				@client = new WebSocketClient()
				
				@client.on "connectFailed", (error) =>
					@emit "error", error
				
				@client.on "connect", (connection) =>
					@connected = true
					
					connection.on "error", (error) ->
						@emit "error", error
										
					connection.on "message", (recMessage) =>
						recMessage = recMessage.utf8Data
						@emit "newMessage", recMessage
						connection.close()
					
					connection.sendUTF message
				
				addr = "#{@transport.toLowerCase()}://#{@target}:#{@port}"
				if @path
					addr += "/#{@path}"
				@client.connect addr, "sip"
				setTimeout callback, @timeOut
