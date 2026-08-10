refPromises =
  main: null
  encounter: null

geripsy.service 'RefLookupService', ['$http', '$q', 'CONSTANTS', ($http, $q, CONSTANTS) ->
  lookupTypes =
    main: '/api/ref_lookups'
    encounter: '/api/ref_lookups?group=encounters'

  getLookups = (type)->
    if refPromises[type] == null
      refPromises[type] = $http.get(lookupTypes[type]).then (data) ->
        data.data

    refPromises[type]


  return {
    getRefLookupLocal: (type, prefix) ->
      getLookups(type).then (data) ->
        _.map(data[prefix], (e) ->
          e.name = e.keyname
          e.val = e.keyvalue
          e.description = e.description if e.description
          e
        )

    lookupFromKey: (type, prefix, key) ->
      return unless key
      getLookups(type).then (data) ->
        _.find(data[prefix], (i)-> i.keyname is key).keyvalue
  }
]
