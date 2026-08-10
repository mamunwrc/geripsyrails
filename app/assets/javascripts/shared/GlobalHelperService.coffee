geripsy.factory 'GlobalHelpers', ->
  objectify = (collection, key, val) ->
    _.map collection, (item) ->
      keyname: item[key]
      keyvalue: item[val]

  return {
    objectify: objectify
  }
