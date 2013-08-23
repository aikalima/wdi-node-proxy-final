#https://github.com/MatthewMueller/cheerio
cheerio = require 'cheerio'

init = (body) ->
  $ = cheerio.load(body)

  user =
    name: $("meta[property='og:title']").attr("content")
    description: $("meta[property='og:description']").attr("content")
    image: $("meta[property='og:image']").attr("content")
    url: $("meta[property='og:url']").attr("content")

module.exports.init = init
