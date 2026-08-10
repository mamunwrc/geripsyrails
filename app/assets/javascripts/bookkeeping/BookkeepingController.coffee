geripsy.controller "BookkeepingController", ['$scope', '$http', '$state', ($scope, $http, $state) ->

  $scope.emailSent = false
  $scope.date = new Date()

  $scope.sendBookkeepingEmail = ->
    $scope.emailSent = true
    $http.post('/api/bookkeeping', { date: $scope.date })
]
