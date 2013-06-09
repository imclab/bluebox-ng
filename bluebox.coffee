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

readline = require "readline"
fs = require "fs"
{Printer} = require "./src/tools/printer"
{Grammar} = require "./src/tools/grammar"
{Utils} = require "./src/tools/utils"
{ExtIp} = require "./src/tools/extIp"
{SipDns} = require "./src/modules/sipDns"
{SipScan} = require "./src/modules/sipScan"
{SipBruteExt} = require "./src/modules/sipBruteExt"
{SipBruteExtAst} = require "./src/modules/sipBruteExtAst"
{SipBrutePass} = require "./src/modules/sipBrutePass"
{Shodan} = require "./src/modules/shodan"
{MaxMind} = require "./src/modules/maxMind"
{DefaultPass} = require "./src/modules/defaultPass"
{GoogleDorks} = require "./src/modules/googleDorks"
{WebDiscover} = require "./src/modules/webDiscover"
{SipFlood} = require "./src/modules/sipFlood"
{SipUnAuth} = require "./src/modules/sipUnAuth"
{SipInvSpoof} = require "./src/modules/sipInvSpoof"
{SipUnreg} = require "./src/modules/sipUnreg"
{SipBye} = require "./src/modules/sipBye"
{DumbFuzz} = require "./src/modules/dumbFuzz"
{BashCommand} = require "./src/modules/bashCommand"


# --------------------- Functions --------------------------------

# It gets the default port for each transport
portTransport = (transport) ->
	switch transport
		when "UDP", "TCP"
			port = 5060
		when "TLS"
			port = 5061
		when "WS"
			port = 8080
		when "WSS"
			port = 4443


# It prints informational message launched on each init Bluebox.
printWelcome = () ->
	Printer.info "Type "
	Printer.highlight "\"help\""
	Printer.info " to see available commands.\n"
	Printer.info "If you have doubts just use the default options :).\n"


# It prints info about avaliable commands.
printCommands = () ->
	Printer.infoHigh "\nSEARCH\n"
	Printer.highlight "shodan-search: "
	Printer.normal "Find potential targets in SHODAN computer search engine.\n"
	Printer.highlight "shodan-pop: "
	Printer.normal "Quick access to popular SHODAN VoIP related queries.\n"
	Printer.highlight "google-dorks: "
	Printer.normal "Find potential targets using a Google dork.\n"
	Printer.infoHigh "\nSIP\n"
#	Printer.highlight "sip-auto: "
#	Printer.normal "Automate SIP pentesting process.\n"
	Printer.highlight "sip-dns: "
	Printer.normal "DNS SRV and NAPTR discovery.\n"
	Printer.highlight "sip-scan: "
	Printer.normal "A SIP host/port scanning tool.\n"
	Printer.highlight "sip-brute-ext: "
	Printer.normal "Try to brute-force valid extensions of the SIP server.\n"
	Printer.highlight "sip-brute-ext-ast: "
	Printer.normal "Try to brute-force valid extensions in Asterisk (CVE-2011-4597).\n"
	Printer.highlight "sip-brute-pass: "
	Printer.normal "Try to brute-force the password for an extension.\n"
	Printer.highlight "sip-unauth: "
	Printer.normal "Try know if a SIP server allows unauthenticated calls.\n"
	Printer.highlight "sip-inv-spoof: "
	Printer.normal "Make a call with an spoofed caller id.\n"
	Printer.highlight "sip-unreg: "
	Printer.normal "Try to unregister another endpoint.\n"
	Printer.highlight "sip-bye: "
	Printer.normal "Use BYE teardown to end an active call.\n"
	Printer.highlight "sip-flood: "
	Printer.normal "Denial of service (DoS) protection mechanism stress test.\n"
	Printer.highlight "dumb-fuzz: "
	Printer.normal "Really stupid fuzzer.\n"
	Printer.infoHigh "\nWEB\n"
#	Printer.highlight "web-auto: "
#	Printer.normal "Discover and bruteforce common web panel of VoIP servers in a host.\n"
	Printer.highlight "web-discover: "
	Printer.normal "Discover common web panel of a VoIP servers in a host (dirscan-node).\n"
#	Printer.highlight "web-brute: "
#	Printer.normal "Bruteforce credentials of a VoIP server web panel.\n"
	Printer.infoHigh "\nMORE\n"
	Printer.highlight "shodan-host: "
	Printer.normal "Get indexed info of an IP address in SHODAN.\n"
	Printer.highlight "shodan-vulns': "
	Printer.normal "Find vulnerabilities and exploit of an specifig service version.\n"
	Printer.highlight "shodan-query: "
	Printer.normal "Use a customized SHODAN VoIP query.\n"
	Printer.highlight "shodan-download: "
	Printer.normal "Download an exploit.\n"
	Printer.highlight "default-pass: "
	Printer.normal "Show common VoIP system default passwords.\n"
	Printer.highlight "geo-locate: "
	Printer.normal "Geolozalization of a host using Maxmind DB.\n"
	Printer.highlight "get-ext-ip: "
	Printer.normal "Get you external IP address (icanhazip.com).\n"
	Printer.infoHigh "\nENV\n"
	Printer.highlight "clear: "
	Printer.normal "Clear the environment.\n"
	Printer.highlight "help: "
	Printer.normal "Print this info.\n"
	Printer.highlight "version: "
	Printer.normal "Print the version of this software.\n"
	Printer.highlight "quit / exit: "
	Printer.normal "Close the program.\n\n"


# Command completion definition.
completer = (line) ->
	completions = "\nall-auto shodan-search shodan-pop google-dorks "
	completions += "sip-dns sip-scan sip-brute-ext sip-brute-ext-ast sip-brute-pass "
	completions += "sip-unauth sip-inv-spoof sip-unreg "
	completions += "sip-bye sip-flood dumb-fuzz "
	completions += "web-discover "
	completions += "shodan-host shodan-vulns shodan-query shodan-download default-pass "
	completions += "geo-locate get-ext-ip clear help version quit exit"
	completSplit = completions.split " "
	hits = completSplit.filter((c) ->
		c.indexOf(line) is 0
	)
	# Show all completions if none found.
	[(if hits.length+1 then hits else completions), line]


runMenu = (shodanKey) ->
	# Command line interpreter is started (readline).
	rl = readline.createInterface process.stdin, process.stdout, completer
	rl.setPrompt "Bluebox-ng> "
	rl.prompt()

	# Default parameters.
	version = "Pre-alpha (0.0.1)"
	target = "0.0.0.0"
	transportTypes= ["UDP", "TCP", "TLS", "WS", "WSS"]
	transport = "UDP"
	port = 5060
	requestTypes = ["REGISTER", "INVITE", "OPTIONS", "MESSAGE", "BYE", "OK", "CANCEL", "ACK", "Ringing", "SUBSCRIBE", "PUBLISH", "NOTIFY"]
	rtype = "OPTIONS"
	path = ""
	# TODO: Available: 4 (ipv4), 6 (ipv6).
	# ipVersion = 4
	# Delay between requests.
	delay = 100
	rangeExt = "100-999"
	onlyExt = "100"
	onlyExtTo = "bluebox"
	passwords = "100"
	callerId = "bluebox"
	callId = "ffffffff"
	targetWeb = "http://192.168.122.135"
	cseq = "1"
	fromTag = ""
	toTag = ""
	fuzzString = "A"
	fuzzMin = "1"
	fuzzMax = "100"

	# ---- Readline events ----

	# On new line, it's parsed and related module is launched with chosen params.
	rl.on "line", (line) ->
		switch line.trim()
			when "shodan-search"
				Printer.configure()
				if not shodanKey
					Printer.error "You must provide your private SHODAN API key, please take a look to the README file."
				else
					rl.question "* Service (None): ", (answer) ->
						service = answer
						rl.question "* Version (None): ", (answer) ->
							version = answer
							rl.question "* Port (None): ", (answer) ->
								port = answer
								Printer.info "Really a few requests are allowed without a SHODAN premium account.\n"
								Printer.info "ie: DE, US, GB, JP, RO, ES\n"
								rl.question "* Country (None): ", (answer) ->
									# Without a premium account only one page is allowed.
									pages = "1"
									country = answer
									Shodan.searchTargets service, version, port, country, pages, shodanKey
			when "shodan-host"
				Printer.configure()
				if not shodanKey
					Printer.error "You must provide your private SHODAN API key, please take a look to the README file."
				else
					rl.question "* Target (1.1.1.1): ", (answer) ->
						answer = "1.1.1.1" if answer is ""
						if (Grammar.ipRE.exec answer)
							target = answer
							Shodan.searchHost target, shodanKey
						else
							Printer.error "Invalid target"
			when "shodan-vulns"
				Printer.configure()
				if not shodanKey
					Printer.error "You must provide your private SHODAN API key, please take a look to the README file."
				else
					rl.question "* Service (FreePBX): ", (answer) ->
						answer = "freepbx" if answer is ""
						service = answer
						rl.question "* Version (None): ", (answer) ->
							version = answer
							Shodan.searchVulns service, version, shodanKey
			when "shodan-query"
				Printer.configure()
				if not shodanKey
					Printer.error "You must provide your private SHODAN API key, please take a look to the README file."
				else
					rl.question "* Query (Asterisk): ", (answer) ->
						answer = "Asterisk" if answer is ""
						query = answer
						# TODO: Add pages, for now, they are not included to be more clear
						pages = "1"
						Shodan.searchQuery query, pages, shodanKey
			when "shodan-download"
				Printer.error "Still not implemented in SHODAN, so we have to download it manually for now :(."
	#			Shodan.download "18659", shodanKey
			when "shodan-pop"
				Shodan.searchPopular()
			when "google-dorks"
				GoogleDorks.print()
			when "sip-dns"
				rl.question "* Domain (sip2sip.info): ", (answer) ->
					answer = "sip2sip.info" if answer is ""
					dnsDomain = answer
					SipDns.run dnsDomain
			when "sip-scan"
				Printer.configure()
				# TODO: Support CIRD format and another masks
				Printer.info "ie: 192.168.122.1, 192.168.122.1-254, 192.168.122.1-192.168.122.254\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					# TODO: Change all these controls
					if (Grammar.ipRE.exec target or Grammar.ipRangeRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											Printer.info  "#{requestTypes}\n"
											rl.question "* Type (OPTIONS): ", (answer) ->
												answer = "OPTIONS" if answer is ""
												if answer in requestTypes
													rtype = answer
													Printer.info "tip: Only needed scanning ranges\n"
													rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
														answer = delay if answer is ""
														delay = answer
														if transport is "WS" or transport is "WSS"	
															Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
															Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
															rl.question "* Path (#{path}): ", (answer) ->
																path = answer
																SipScan.run target, port, path, srcHost, transport, rtype, shodanKey, delay
														else
															SipScan.run target, port, "", srcHost, transport, rtype, shodanKey, delay
												else
													Printer.error "Invalid type"		
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-brute-ext"
				Printer.configure()
				Printer.info "ie: 192.168.122.1\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											Printer.info "ie: \"100-999\", \"./data/extensions.txt\"\n"
											rl.question "* Enter an extension, a range or a file (#{rangeExt}): ", (answer) ->
												answer = rangeExt if answer is ""
												rangeExt = answer
												rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
													answer = delay if answer is ""
													delay = answer
													if transport is "WS" or transport is "WSS"									
														Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
														Printer.info "tip: Final format \"ws://Target:Port:Path\"\n"
														rl.question "* Path (#{path}): ", (answer) ->
															path = answer
															SipBruteExt.run target, port, path, srcHost, transport, "REGISTER", rangeExt, delay
													else
															SipBruteExt.run target, port, "", srcHost, transport, "REGISTER", rangeExt, delay
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-brute-ext-ast"
				Printer.configure()
				Printer.info "ie: 192.168.122.1\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						rl.question "* Port (5060): ", (answer) ->
							answer = "5060" if answer is ""
							port = answer
							if (Grammar.portRE.exec answer)
								port = answer										
								Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
								rl.question "* Source IP, SIP layer (random): ", (answer) =>
									srcHost = answer
									Printer.info "ie: 100, \"100-999\", \"./data/extensions.txt\"\n"
									rl.question "* Enter an extension, a range or a file (#{rangeExt}): ", (answer) ->
										answer = rangeExt if answer is ""
										rangeExt = answer
										rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
											answer = delay if answer is ""
											delay = answer
											SipBruteExtAst.run target, port, srcHost, rangeExt, delay
							else
								Printer.error "Invalid port"
					else
						Printer.error "Invalid target"
			when "sip-brute-pass"
				Printer.configure()
				Printer.info "ie: 192.168.122.1\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											Printer.info "ie: \"100\", \"100-999\", \"./data/extensions.txt\"\n"
											rl.question "* Enter an extension, a range or a file (#{onlyExt}): ", (answer) ->
												answer = onlyExt if not answer
												onlyExt = answer
												Printer.info "ie: \"100\", \"./data/passwords.txt\"\n"
												rl.question "* Enter an password or a file (./data/passwords.txt): ", (answer) ->
													answer = "./data/passwords.txt" if not answer
													passwords = answer
													Printer.info "#{requestTypes}\n"
													rl.question "* Type (REGISTER): ", (answer) ->
														answer = "REGISTER" if answer is ""
														if answer in requestTypes
															rtype = answer
															rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
																answer = delay if answer is ""
																delay = answer
																if transport is "WS" or transport is "WSS"									
																	Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
																	Printer.info "tip: Final format \"ws://Target:Port:Path\"\n"
																	rl.question "* Path (#{path}): ", (answer) ->
																		path = answer
																		SipBrutePass.run target, port, path, srcHost, transport, rtype, onlyExt, delay, passwords
																else
																		SipBrutePass.run target, port, "", srcHost, transport, rtype, onlyExt, delay, passwords
														else
															Printer.error "Invalid type"		
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-unauth"
				Printer.configure()
				Printer.info "ie: 192.168.122.1\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											rl.question "* Enter a numer/extension to use in the from (bluebox): ", (answer) ->
												answer = "bluebox" if not answer
												fromExt = answer
												rl.question "* Enter a number/extension to call (100): ", (answer) ->
													answer = "100" if not answer
													toExt = answer
													if transport is "WS" or transport is "WSS"									
														Printer.info  "tip: You should provide a \"Path\" using WS (or WSS)\n"
														Printer.info  "tip: Final format \"ws://Target:Port:Path\"\n"
														rl.question "\n* Path (#{path}): ", (answer) ->
															path = answer
															SipUnAuth.run target, port, path, srcHost, transport, fromExt, toExt
													else
															SipUnAuth.run target, port, "", srcHost, transport, fromExt, toExt
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-inv-spoof"
				Printer.configure()
				# TODO: Support CIRD format and another masks
				Printer.info "ie: 192.168.122.1, 192.168.122.1-254, 192.168.122.1-192.168.122.254\n"
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					if (Grammar.ipRE.exec target or Grammar.ipRangeRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											Printer.info "ie: \"100\", \"100-999\", \"./data/extensions.txt\"\n"
											rl.question "* Enter an extension to call, a range or a file (100): ", (answer) ->
												answer = "100" if not answer
												rangeExt = answer
												rl.question "* CallerID (#{callerId}): ", (answer) ->
													answer = callerId if answer is ""
													callerId = answer
													rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
														answer = delay if answer is ""
														delay = answer
														if transport is "WS" or transport is "WSS"
															Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
															Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
															rl.question "\n* Path (#{path}): ", (answer) ->
																path = answer
																SipInvSpoof.run target, port, path, srcHost, transport, rangeExt, delay, callerId
														else
															SipInvSpoof.run target, port, "", srcHost, transport, rangeExt, delay, callerId
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-unreg"
				Printer.configure()
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					# TODO: Change all these controls
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											rl.question "* Extension to un-register (From) (#{onlyExt}): ", (answer) ->
												answer = onlyExt if answer is ""
												onlyExt = answer
												rl.question "* Cseq (#{cseq}): ", (answer) ->
													answer = cseq if answer is ""
													cseq = answer
													rl.question "* Call-ID (#{callId}): ", (answer) ->
														answer = callId if answer is ""
														callId = answer
														if transport is "WS" or transport is "WSS"								
															Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
															Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
															rl.question "\n* Path (#{path}): ", (answer) ->
																path = answer
																SipUnreg.run target, port, path, srcHost, transport, onlyExt, cseq, callId
														else
															SipUnreg.run target, port, "", srcHost, transport, onlyExt, cseq, callId
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-bye"
				Printer.configure()
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					# TODO: Change all these controls
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											rl.question "* From: (#{onlyExt}): ", (answer) ->
												answer = onlyExt if answer is ""
												onlyExt = answer
												rl.question "* To: (#{onlyExtTo}): ", (answer) ->
													answer = onlyExtTo if answer is ""
													onlyExtTo = answer
													rl.question "* Cseq (#{cseq}): ", (answer) ->
														answer = cseq if answer is ""
														cseq = answer
														rl.question "* Call-ID (#{callId}): ", (answer) ->
															answer = callId if answer is ""
															callId = answer
															rl.question "* From tag (random): ", (answer) ->
																fromTag = answer
																rl.question "* To tag (random): ", (answer) ->
																	toTag = answer
																	if transport is "WS" or transport is "WSS"								
																		Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
																		Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
																		rl.question "* Path (#{path}): ", (answer) ->
																			path = answer
																			SipBye.run target, port, path, srcHost, transport, onlyExt, onlyExtTo, cseq, callId, fromTag, toTag
																	else
																		SipBye.run target, port, "", srcHost, transport, onlyExt, onlyExtTo, cseq, callId, fromTag, toTag
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "sip-flood"
				Printer.configure()
				rl.question "* Target (#{target}): ", (answer) ->
					answer = target if answer is ""
					target = answer
					# TODO: Change all these controls
					if (Grammar.ipRE.exec target) and (target isnt "0.0.0.0")
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer										
										Printer.info "tip: Use comand \"get-ext-ip\" to get you external IP automatically\n"
										rl.question "* Source IP, SIP layer (random): ", (answer) ->
											srcHost = answer
											rl.question "* Numer of requests (infinite): ", (answer) ->
												answer = "infinite" if answer is ""
												numReq = answer
												Printer.info "opt:#{requestTypes}\n"
												rl.question "* Type (OPTIONS): ", (answer) ->
													answer = "OPTIONS" if answer is ""
													if answer in requestTypes
														rtype = answer
														rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
															answer = delay if answer is ""
															delay = answer
															if transport is "WS" or transport is "WSS"									
																Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
																Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
																rl.question "* Path (#{path}): ", (answer) ->
																	path = answer
																	SipFlood.run target, port, path, srcHost, transport, rtype, numReq, delay
															else
																SipFlood.run target, port, "", srcHost, transport, rtype, numReq, delay
													else
														Printer.error "Invalid type"		
									else
										Printer.error "Invalid port"
							else
								Printer.error "Invalid transport"
					else
						Printer.error "Invalid target"
			when "dumb-fuzz"
				Printer.configure()
				rl.question "* Target (127.0.0.1): ", (answer) ->
					answer = "127.0.0.1" if answer is ""
					target = answer
					if ((Grammar.ipRE.exec target) and (target isnt "0.0.0.0"))
						Printer.info "opt:#{transportTypes}\n"
						rl.question "* Transport (#{transport}): ", (answer) ->
							answer = transport if answer is ""
							if answer in transportTypes
								transport = answer
								port = portTransport transport
								rl.question "* Port (#{port}): ", (answer) ->
									answer = port if answer is ""
									if (Grammar.portRE.exec answer)
										port = answer
										rl.question "* Delay between requests (ms.) (#{delay}): ", (answer) ->
											answer = delay if answer is ""
											delay = answer
											Printer.info "ie: A, 2600, fuzzString\n"
											rl.question "* String/char to send (#{fuzzString}): ", (answer) ->
												answer = fuzzString if answer is ""
												fuzzString = answer
												rl.question "* Min. lenght of the string to fuzz (#{fuzzMin}): ", (answer) ->
													answer = fuzzMin if answer is ""
													fuzzMin = answer
													rl.question "* Max. lenght of the string to fuzz (#{fuzzMax}): ", (answer) ->
														answer = fuzzMax if answer is ""
														fuzzMax = answer
														if (fuzzMax is "0")
															Printer.error "You are not fuzzing anything with Max. lenght = 0"
														else
															if ((Utils.isNumber parseInt(fuzzMax)))
																if transport is "WS" or transport is "WSS"									
																	Printer.info "tip: You should provide a \"Path\" using WS (or WSS)\n"
																	Printer.info "tip: Final format \"ws:\\Target:Port:Path\"\n"
																	rl.question "\n* Path (#{path}): ", (answer) ->
																		path = answer
																		DumbFuzz.run target, port, path, transport, fuzzString, fuzzMin, fuzzMax, delay
																else
																	DumbFuzz.run target, port, "", transport, fuzzString, fuzzMin, fuzzMax, delay
															else
																Printer.error "Bad Max. lenght"
									else
										Printer.error "Bad port"
					else
						Printer.error "Bad target"
			when "web-discover"
				Printer.configure()
				Printer.info "ie: 192.168.122.135, http://192.168.122.135, http://anydomain.com, https://anydomain.com\n"
				rl.question "* Target (#{targetWeb}): ", (answer) ->
					answer = targetWeb if answer is ""
					targetWeb = answer
					if ((Grammar.ipRE.exec targetWeb) or (Grammar.httpRE.exec targetWeb))
						Printer.info "ie: quick, large\n"
						rl.question "* Type (quick): ", (answer) ->
							answer = "quick" if answer is ""
							type = answer
							if type in ["quick", "large"]
								WebDiscover.run targetWeb, type
							else
								Printer.error "Bad Type"
					else
						Printer.error "Bad target"
			when "default-pass"
				DefaultPass.print()
			when "geo-locate"
				Printer.configure()
				rl.question "* Target (8.8.8.8): ", (answer) ->	
					answer = "8.8.8.8" if answer is ""
					ltarget = answer
					MaxMind.locate ltarget
			when "get-ext-ip"
				ExtIp.get()
			when "clear"
				Printer.clear()
			when "help"
				printCommands()
			when "version"
				Printer.result version
			when "quit", "exit"
				Utils.quit()
			when ""
				# Nothing is printed in case the user pulses ENTER without provide a command.
				Printer.normal "\n"
			else
				BashCommand.run line
		rl.prompt()		

	# ---- System events ----
	
	# On Ctrl+C, Ctrl+D, etc.
	rl.on "close", () =>
		Utils.quit()


# ------------------------ Main ----------------------------------

# It reads options.json file and if everything is fine main code is executed.
# It print init informational message.
Printer.welcome()
printWelcome()
shodanKey = ""
fs.readFile "./options.json", (err, data) ->
	if err
		Printer.error "Reading \"options.json\" file: #{err}"
	else
		jsonData = JSON.parse data
		if jsonData.firstRun is "yes"
			Printer.error "You should run \"./setup.sh\" before"
		else
			runMenu jsonData.shodanKey
