geripsy.controller "ShippingController", ['$scope', '$http', '$state', ($scope, $http, $state) ->

  $scope.claimsShipped = false

  $scope.shipClaims = ->
    $scope.claimsShipped = true
    $http.post('/api/shipping')
]
