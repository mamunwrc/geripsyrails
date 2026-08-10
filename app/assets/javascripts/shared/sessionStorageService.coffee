class SessionStorageService
  constructor: ($window, $cookies) ->
    @window = $window
    @cookies = $cookies
    @storageAvailable = typeof Storage isnt 'undefined'
  get: (key) ->
    if @storageAvailable
      @window.localStorage.getItem key
    else
      $cookies.get key
  set: (key, value) ->
    if @storageAvailable
      @window.localStorage.setItem key, value
    else
      @cookies.put key, value
    value
  clear: (key) ->
    if @storageAvailable
      @window.localStorage.removeItem key
    else
      @cookies.remove key
    return
  exists: (key) ->
    !_.isUndefined(@get(key))

geripsy.factory 'SessionStorage', [
  '$window'
  '$cookies'
  ($window, $cookies) ->
    new SessionStorageService($window, $cookies)
]
