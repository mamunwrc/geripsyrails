geripsy.factory 'VersionInterceptor', ['$q', '$rootScope', ($q, $rootScope) ->
  response: (resp) ->
    if version = resp.headers('x-geripsy-version')
      $rootScope.SERVER_VERSION = version

    resp.config ?= {}
    resp

  responseError: (rejection) ->
    rejection.config ?= {}
    console.log rejection

    if rejection.status is 416 and rejection.data?.message is "invalid range error"
      $rootScope.global.pagination.page = 0
    $q.reject rejection
]

geripsy.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'VersionInterceptor'
]
