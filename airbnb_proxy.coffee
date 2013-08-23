#http://expressjs.com/
express = require 'express'

#https://github.com/flatiron/nconf
nconf = require 'nconf'

#http://docs.nodejitsu.com/articles/HTTP/clients/how-to-create-a-HTTP-request
https = require 'https'

url = require 'url'
querystring = require 'querystring'

# Standard JS libs
_ = require 'underscore'
require 'sugar' # extends prototypes globally

# my libs / modules

User = require './lib/User.js'
Listing = require './lib/Listing.js'
SearchResult = require './lib/SearchResult.js'

#http://nodejs.org/api/modules.html
app = module.exports = express()

AirbnbDate =
  create: (mmddyyyy) ->
    year = mmddyyyy.substring 4,8
    mm = mmddyyyy.substring 0,2
    dd = mmddyyyy.substring 2,4
    d = new Date('' + year + '-' + mm + '-' + dd)
    d.format '{MM}%2F{dd}%2F{yyyy}'

app.configure ->
  # read in environment or command-line arguments first
  #  - priority is given to the first entry found, i.e. args > env > environment.config > config
  # environment options can be set like this:
  #   set/export proxy:port=12345
  #
  # argument options can be set like this:
  #  node app.js --proxy:port=12345
  nconf.argv().env()
  nconf.add 'default-file', {type: 'file', file: "config.json"}

  #console.log nconf.get "airbnb:host"
  #console.log nconf.get "proxy:port"

proxy_port = nconf.get "proxy:port"
app.listen proxy_port
console.log 'Airbnb proxy listening on port:' + proxy_port

# API ######
app.get '/hello.txt', (req, res) ->
  res.send 'Hello World'

# profile page
# http://localhost:4000/user/530020
# -> https://www.airbnb.com/users/show/530020
app.get '/user/:id', (req, res) ->
  userId = req.params.id
  airbnb_path = '/users/show/'+userId
  app.local.fetch User, airbnb_path, (user) ->
    res.send JSON.stringify user

# listing page
# http://localhost:4000/listing/101052
# -> https://www.airbnb.com/rooms/101052
app.get '/listing/:id', (req, res) ->
  listingId = req.params.id
  airbnb_path = '/rooms/'+listingId
  app.local.fetch Listing, airbnb_path, (listing) ->
    res.send JSON.stringify listing

# Location search with dates
# http://localhost:4000/search/los angeles/08212013/08242013?guests=3
# -> https://www.airbnb.com/s/los-angeles?checkin=08%2F21%2F2013&checkout=08%2F24%2F2013&guests=3
app.get '/search/:location/:checkin/:checkout', (req, res) ->
  location = req.params.location.replace ' ','-' #airbnb search uses '-' for white space

  #transform dates
  #mmddyyy -> 02%2F01%2F2011
  checkin = AirbnbDate.create req.params.checkin
  checkout = AirbnbDate.create req.params.checkout

  #we do this for guests
  query = (url.parse req.url).query
  queryObj = querystring.parse query
  if queryObj.guests then guests=queryObj.guests else guests=2

  airbnb_path = '/s/'+location+'?checkin='+checkin+'&checkout='+checkout+'&guests='+guests
  app.local.fetch SearchResult, airbnb_path, (results) ->
    res.send JSON.stringify results

# LOCAL FUNCTION ######
app.local = {}

app.local.fetch = (entity, airbnb_path, callback) ->
  https.get "https://"+ nconf.get("airbnb:host") + airbnb_path, (res) ->
    console.log "Got response: " + res.statusCode
    body = ''
    c = 0
    res.on 'data', (chunk) ->
      body += chunk
    res.on 'end', () ->
      callback entity.init(body)


