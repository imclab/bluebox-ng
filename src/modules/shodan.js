// Generated by CoffeeScript 1.6.3
/*

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
*/

var Printer, Shodan, baseUrl, popularUrl, request, xml2js;

request = require("request");

xml2js = require("xml2js");

Printer = require("../tools/printer").Printer;

exports.Shodan = Shodan = (function() {
  var callback, connected, printHostData, printPopInfo, printTargetInfo, printVulnsInfo, timeOut;

  function Shodan() {}

  connected = false;

  timeOut = 20000;

  printVulnsInfo = function(info) {
    Printer.info("\n\nName: ");
    Printer.normal(info.name);
    Printer.info("\nSource: ");
    Printer.normal(info.source);
    Printer.info("\nLink: ");
    Printer.normal(info.link);
    Printer.info("\nID: ");
    return Printer.result("" + info.id);
  };

  printTargetInfo = function(info) {
    Printer.info("\n\nServer: ");
    Printer.result("" + info.ip + ":" + info.port);
    Printer.normal(" (updated: " + info.updated + ")");
    Printer.info("\nLocation: ");
    Printer.normal("" + info.city + ", " + info.country_name + " (" + info.longitude + ", " + info.latitude + ")");
    Printer.info("\nResponse:\n");
    return Printer.normal("" + info.data);
  };

  printHostData = function(info) {
    var info2, _i, _len, _ref, _results;
    Printer.info("\n\nHost: ");
    Printer.result("" + info.ip);
    Printer.info("\nCountry: ");
    Printer.normal("" + info.country_code);
    Printer.info("\nCity: ");
    Printer.normal("" + info.city);
    Printer.info("\nPosition: ");
    Printer.normal("(" + info.longitude + ", " + info.latitude + ")");
    Printer.info("\nData:\n");
    _ref = info.data;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      info2 = _ref[_i];
      Printer.infoHigh("\nPort: ");
      Printer.normal("" + info2.port);
      Printer.infoHigh("\nOrganization: ");
      Printer.normal("" + info2.org);
      Printer.infoHigh("\nBanner:\n");
      _results.push(Printer.normal("" + info2.banner + "\n"));
    }
    return _results;
  };

  printPopInfo = function(info) {
    var query, queryRE, tag;
    Printer.info("\nTitle: ");
    Printer.normal("" + info.title);
    Printer.info("\nSummary: ");
    Printer.normal(info.summary[0]._);
    tag = info.id.toString();
    queryRE = /\:\/\?q=*/;
    query = tag.slice((tag.search(queryRE)) + 5);
    Printer.info("\nQuery: ");
    Printer.result("\"" + query + "\"");
    Printer.info("\nLast updated: ");
    return Printer.normal("" + info.updated + "\n");
  };

  callback = function() {
    if (!connected) {
      return Printer.error("Connection problem: Can't reach the target or no response");
    }
  };

  Shodan.searchVulns = function(service, version, key) {
    setTimeout(callback, timeOut);
    console.log("" + baseUrl + "search_exploits?q=" + service + "+" + version + "&key=" + key);
    return request.get({
      uri: "" + baseUrl + "search_exploits?q=" + service + "+" + version + "&key=" + key,
      json: true
    }, function(err, r, body) {
      var info, _i, _len, _ref, _results;
      connected = true;
      if (err) {
        return Printer.error("Shodan: connection problem: " + err);
      } else {
        if (body.error) {
          return Printer.error("Shodan: " + body.error);
        } else {
          if (body.total !== 0) {
            _ref = body.matches;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              info = _ref[_i];
              _results.push(printVulnsInfo(info));
            }
            return _results;
          } else {
            return Printer.highlight("\nNo vulns found.\n");
          }
        }
      }
    });
  };

  Shodan.searchQuery = function(query, pages, key) {
    setTimeout(callback, timeOut);
    return request.get({
      uri: "" + baseUrl + "search?q=" + query + "&p=" + pages + "&key=" + key,
      json: true
    }, function(err, r, body) {
      var info, results, _i, _len;
      connected = true;
      if (err) {
        return Printer.error("Shodan: connection problem: " + err);
      } else {
        if (body.error) {
          return Printer.error("Shodan: " + body.error);
        } else {
          results = body.matches;
          if (body.total !== 0) {
            for (_i = 0, _len = results.length; _i < _len; _i++) {
              info = results[_i];
              if (info.city) {
                printTargetInfo(info);
              }
            }
            Printer.info("\n\nTotal: ");
            return Printer.result(body.total + "\n");
          } else {
            return Printer.highlight("\nNo hosts found :(\n");
          }
        }
      }
    });
  };

  Shodan.searchTargets = function(service, version, port, country, pages, key) {
    var query;
    query = "" + service;
    if (version) {
      query += "+" + version;
    }
    if (port) {
      query += "+port%3A" + port;
    }
    if (country) {
      query += "+country%3A" + country;
    }
    return this.searchQuery(query, pages, key);
  };

  Shodan.searchHost = function(ipAddress, key) {
    setTimeout(callback, timeOut);
    return request.get({
      uri: "" + baseUrl + "host?ip=" + ipAddress + "&key=" + key,
      json: true
    }, function(err, r, body) {
      connected = true;
      if (err) {
        return Printer.error("Shodan: connection problem: " + err);
      } else {
        if (body.error) {
          return Printer.error("Shodan: " + body.error);
        } else {
          return printHostData(body);
        }
      }
    });
  };

  Shodan.searchPopular = function() {
    setTimeout(callback, timeOut);
    return request.get({
      uri: "" + popularUrl,
      json: false
    }, function(err, r, body) {
      var parser;
      connected = true;
      if (err) {
        return Printer.error("Shodan: connection problem: " + err + ".");
      } else {
        if (body.error) {
          return Printer.error("Shodan: " + body.error);
        } else {
          parser = new xml2js.Parser().parseString;
          return parser(body, function(err, result) {
            var info, _i, _len, _ref, _results;
            _ref = result.feed.entry;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              info = _ref[_i];
              _results.push(printPopInfo(info));
            }
            return _results;
          });
        }
      }
    });
  };

  Shodan.download = function(id, key) {
    return console.log("" + baseUrl + "exploitdb/download?id=" + id + "&key=" + key);
  };

  return Shodan;

})();

baseUrl = "http://www.shodanhq.com/api/";

popularUrl = "http://www.shodanhq.com/browse/tag/voip?feed=1";
