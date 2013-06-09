###

Copyright (C) 2013, Jesus Perez <jesusprubio gmail com>
Copyright (C) 2013, Damian Franco <pamojarpan gmail com>

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

{Utils} = require "./utils.coffee"
undScore = require "underscore"
crypto = require "crypto"


# ----------------------- Class ----------------------------------

# This class is used to define the structure of a valid SIP packet following
# RFC 3261 (http://www.ietf.org/rfc/rfc3261.txt) and its extensions.
# SIP requests creator. It creates more or less valid (but standard) SIP requests
# Supported types of request: "REGISTER", "INVITE", "OPTIONS", "MESSAGE", "BYE",
# "OK", "CANCEL", "ACK" and "Ringing". (for now...)
# TODO: Add presence types (¡SUSCRIBE!(auth), NOTIFY, etc.)

exports.SipMessage =
class SipMessage

	constructor : (@meth, @domain, @server, @port, @srcHost, @srcPort, @fromExt, @toExt, @transport, @realm, @nonce, @pass, @isProxy, @cseq, @callId, @gruuInstance, @expires, @fromTag, @toTag) ->
		@domain = @domain or @server
		@toExt = @toExt or Utils.uniqueId 3
		@fromExt = @fromExt or Utils.uniqueId 3
		# Random if not provided.
		@uri = "sip:#{@fromExt}@#{@domain}"
		@toUri = "sip:#{@toExt}@#{@domain}"
		@targetUri = "sip:#{@domain}"
		@branchPad = Utils.uniqueId 30
		# TODO: random better maybe?
		@cseq = @cseq or 1
		@sessionId = undScore.random 1000000000, 9999999999
		@sessionPort = undScore.random 1025, 65535
		# TODO: needed for brute-pass
		@isProxy = false or @isProxy
		@fromTag = @fromTag or Utils.uniqueId 10
		@toTag = @toTag or Utils.uniqueId 10
		@callId = @callId or "#{Utils.uniqueId 16}@#{@domain}"
		@srcHostSdp = @srcHost
		@tupleId = Utils.uniqueId 10
		@srcHost = @srcHost or Utils.randomIP()
		@srcPort = @srcPort or Utils.randomPort()
		@uriVia = "#{@srcHost}:#{@srcPort}"
		@regId = 1
		@gruuInstance = @gruuInstance or "urn:uuid:#{Utils.uniqueId 3}-#{Utils.uniqueId 4}-#{Utils.uniqueId 8}"
		@expires = @expires or "3600"


	# SIP digest calculator as defined in RFC 3261.
	getDigest : (ext, realm, pass, meth, requestUri, nonce) ->
		ha1 = crypto.createHash('md5').update("#{ext}:#{realm}:#{pass}").digest("hex")
		ha2 = crypto.createHash('md5').update("#{meth}:#{requestUri}").digest("hex")
		sol = crypto.createHash('md5').update("#{ha1}:#{nonce}:#{ha2}").digest("hex")
				

	# It creates the packet.
	create : () ->
		# SIP frame is filled.
		switch @meth
			when "REGISTER", "PUBLISH"
				data = "#{@meth} #{@targetUri} SIP/2.0\r\n"
			when "INVITE", "OPTIONS", "MESSAGE", "CANCEL", "ACK", "BYE", "SUBSCRIBE", "NOTIFY"
				data = "#{@meth} #{@toUri} SIP/2.0\r\n"
			when "OK"
				data = "SIP/2.0 200 OK\r\n"
			when "Ringing"
				data = "SIP/2.0 180 Ringing\r\n"
	
		# Via. 
		switch @transport
			when "WS", "WSS"
				@uriVia = "#{Utils.uniqueId 12}.invalid"
		data += "Via: SIP/2.0/#{@transport} #{@uriVia};branch=z9hG4bK#{@branchPad}\r\n"

		# From.
		data += "From: #{@fromExt} <#{@uri}>;tag=#{@fromTag}\r\n"

		# To.
		switch @meth
			when "REGISTER", "PUBLISH"
				data += "To: <#{@uri}>\r\n"
			when "INVITE", "OPTIONS", "MESSAGE", "CANCEL", "SUBSCRIBE", "NOTIFY"
				data += "To: #{@toExt} <#{@toUri}>\r\n"
			else
				data += "To: #{@toExt} <#{@toUri}>;tag=#{@toTag}\r\n"

		# Call-ID.
		data += "Call-ID: #{@callId}\r\n"

		# CSeq.
		switch @meth
			when "Trying", "Ringing", "OK"
				data += "CSeq: #{@cseq} INVITE\r\n"
			else
				data += "CSeq: #{@cseq} #{@meth}\r\n"

		# Max-Forwards.
		data += "Max-Forwards: 70\r\n"

		# Allow.
		switch @meth
			when "REGISTER", "INVITE", "MESSAGE", "SUBSCRIBE", "PUBLISH", "NOTIFY"
				data += "Allow: REGISTER, INVITE, OPTIONS, ACK, CANCEL, BYE, MESSAGE, SUBSCRIBE, PUBLISH, NOTIFY\r\n"
		
		# Supported. 
		switch @transport
			when "WS", "WSS"
				data += "Supported: path, outbound, gruu\r\n"
		
		# User-Agent.
		# The same suffix of SIPVicious is used to avoid sysadmin headaches.
		data += "User-Agent: bluebox-scanner\r\n"
		
		# Presence.
		switch @meth
			when "SUBSCRIBE", "PUBLISH"
				data += "Expires: 2600\r\n"
		switch @meth
			when "SUBSCRIBE", "PUBLISH", "NOTIFY"
				data += "Event: presence\r\n"

		# Contact.
		if @transport is "WS" or @transport is "WSS"
			switch @meth
				when "REGISTER", "OPTIONS", "PUBLISH", "SUBSCRIBE"
					data += "Contact: <sip:#{@fromExt}@#{@uriVia};transport=ws;expires=#{@expires}>"
					data += ";reg-id=#{@regId};sip.instance=\"<#{@gruuInstance}>\"\r\n"
				when "INVITE", "MESSAGE", "OK", "Ringing", "NOTIFY", "CANCEL"
					data += "Contact: <sip:#{@fromExt}@#{@domain}"
					data += ";gr=#{@gruuInstance};ob>\r\n"	
		else
			switch @meth
				when "REGISTER"
					data += "Contact: <sip:#{@fromExt}@#{@uriVia}>;expires=#{@expires}\r\n"	
				when "OPTIONS", "PUBLISH", "SUBSCRIBE"
					data += "Contact: <sip:#{@fromExt}@#{@uriVia}>\r\n"	
				when "INVITE", "MESSAGE", "OK", "Ringing", "NOTIFY", "CANCEL"
					@transport = "TCP" if @transport is "TLS"
					@transport = "WS" if @transport is "WSS"
					data += "Contact: <sip:#{@fromExt}@#{@uriVia};transport=#{@transport.toLowerCase()}>\r\n"
		# Challenge.
		if @nonce
			if @isProxy
				data += "Proxy-Authorization:"
			else
				data += "Authorization:"
			switch @meth
				when "REGISTER", "PUBLISH"
					authUri = @targetUri
				when "INVITE", "OPTIONS", "MESSAGE", "OK", "Ringing", "NOTIFY", "CANCEL", "SUBSCRIBE"
					authUri = @toUri
			response = @getDigest @fromExt, @realm, @pass, @meth, authUri, @nonce
			data += " Digest username=\"#{@fromExt}\", realm=\"#{@realm}\","
			# TODO: Add support to more auth algs.
			data += "nonce=\"#{@nonce}\", uri=\"#{authUri}\", response=\"#{response}\", algorithm=MD5\r\n"	
		# Content-type and content.
		switch @meth
			when "INVITE", "OK"
				sdp = "v=0\r\n"
				sdp += "o=#{@fromExt} #{@sessionId} #{@sessionId} IN IP4 #{@srcHost}\r\n"
				sdp += "s=-\r\n"
				sdp += "c=IN IP4 #{@srcHost}\r\n"
				sdp += "t=0 0\r\n"
				sdp += "m=audio #{@sessionPort} RTP/AVP 0\r\n"
				sdp += "a=rtpmap:0 PCMU/8000\r\n"
				data += "Content-Type: application/sdp\r\n"
				data += "Content-Length: #{sdp.length}\r\n\r\n"
				data += sdp
			when "MESSAGE"
				sdp = "OLA K ASE! ;)\r\n"
				data += "Content-Type: text/plain\r\n"
				data += "Content-Length: #{sdp.length}\r\n\r\n"
				data += sdp
			when "NOTIFY", "PUBLISH"
				sdp = "<presence xmlns=\"urn:ietf:params:xml:ns:pidf\" "
				sdp += "entity=\"sip:#{@toExt}@#{@domain}\">\r\n"
				sdp += "<tuple id=\"#{@tupleId}\">\r\n"
				sdp += "<status>\r\n"
				sdp += "<basic>open</basic>\r\n"
				sdp += "</status>\r\n"
				sdp += "<contact priority=\"0.8\">#{@toExt}@#{@domain}</contact>\r\n"
				sdp += "</tuple>\r\n"
				sdp += "</presence>\r\n"
				data += "Content-Type: application/pidf+xml\r\n"
				data += "Content-Length: #{sdp.length}\r\n\r\n"
				data += sdp
			else
				if @meth is "OPTIONS"
	 				data += "Accept: application/sdp\r\n"
				data += "Content-Length: 0\r\n\r\n"
		return data
