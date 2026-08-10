geripsy.service 'IcdLookupService', ['$http', '$q', ($http, $q) ->
  icdPromise = null

  getIcds = ->
    if icdPromise is null
      icdPromise = $http.get('/api/ref_icds').then (data) -> data.data

    icdPromise

  return {
    getIcds: ->
      getIcds().then (data) -> data
  }
]
