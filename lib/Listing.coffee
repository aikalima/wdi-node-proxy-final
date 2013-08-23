#https://github.com/MatthewMueller/cheerio
cheerio = require 'cheerio'

init = (body) ->
  $ = cheerio.load(body)

  hostingIdTag = body.match(/hostingId.*/g)
  if hostingIdTag == null
    return "Not a listing"

  listing =
    user: $(".name").children()[0]?.attribs.href.replace(/\/users\/show\//g, "")
    displayAddress: $("#display_address").text()
    # nightlyPrice: new String(body.match(/nightlyPrice.*/g)).match(/\d+/g)[0]
    # weeklyPrice: new String(body.match(/weeklyPrice.*/g)).match(/\d+/g)[0]
    # monthlyPrice: new String(body.match(/monthlyPrice.*/g)).match(/\d+/g)[0]
    title: $("meta[property='og:title']").attr("content")
    description: $("meta[property='og:description']").attr("content")
    image: $("meta[property='og:image']").attr("content")
    zip: $("meta[property='airbedandbreakfast:postal-code']").attr("content")
    locality: $("meta[property='airbedandbreakfast:locality']").attr("content")

module.exports.init = init
