
init = (body) ->
  console.log 'matching ..'
  matchStr = body.match(/AirbnbSearch\.resultsJson[^]+uniqueHostingsCount\":\d+};/g)
  if not matchStr? or not matchStr.length then return "no matchs"

  result = matchStr[0]
  result = result.replace 'AirbnbSearch.resultsJson = ',''
  result = result.substring(0, result.length-1)
  result =  eval("(" + result + ')'); # I know I shouldn't be doing this
  result.properties

module.exports.init = init
