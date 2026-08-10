priceShared = ($scope) ->
  $scope.formTemplate = "prices/_prices-edit.html"
  $scope.editRoute = "price.edit({id: price.id})"
  $scope.sectionHome = "prices"

  $scope.formDisabled = ->
    $scope.ctrl.insForm and $scope.ctrl.insForm.$invalid

  $scope.setCreateable 'Adm::CptPrice'
  $scope.setUpdateable 'Adm::CptPrice'

geripsy.controller "PricesController", ['$scope', ($scope) ->
  $scope.sectionList = $scope.prices = []
  $scope.showRoute = "price.show({id: item.id})"
  $scope.addRoute = "pricesNew"
  $scope.title = "CPT Prices"

  $scope.listData ?= (price) ->
    first: price.cpt_code
    second: "$" + price.price
    third: ''

  $scope.apiRoute = "prices"
  priceShared $scope
]

geripsy.controller "PriceController", [
  '$scope'
  '$stateParams'
  '$state'
  '$mdDialog'
  'Price'
  'price'
  ($scope, $stateParams, $state, $mdDialog, Price, price) ->
    $scope.isEditing = $state.current.data.isEditing
    $scope.price = price
    $scope.deleteable = true

    $scope.titleBar = =>
      price.name

    $scope.edit = -> $state.go 'price.edit', $stateParams, reload: true
    $scope.submit = ->
      $scope.price.$update -> $state.go 'prices'

    $scope.delete = (ev) ->
      confirm = $mdDialog.confirm()
        .title 'Irreversible action!'
        .textContent 'Are you SURE you want to delete this price? This action cannot be undone and may disturb other functionality in the system.'
        .ariaLabel 'confirm delete'
        .targetEvent ev
        .ok 'Yes, delete this price'
        .cancel 'Nevermind!'

      $mdDialog.show(confirm).then ->
        $scope.price.$delete ->
          $state.go 'prices'
        , (response) ->
          console.log response
          $scope.Toast.display ["Could not delete price"]

    priceShared $scope
]

geripsy.controller "PriceCreateController", [
  '$scope'
  '$state'
  'Price'
  ($scope, $state, Price) ->
    $scope.isEditing = true
    $scope.price = new Price
    $scope.titlebar = -> "Create new price"

    $scope.submit = ->
      $scope.price.$save ->
        $state.go 'prices'
      , (e) ->
        console.log e
        msgs = ["Price couldn't be saved:"]
        _.each e.data, (v,k) ->
          msgs.push [k, v[0]].join ": "
        $scope.Toast.display msgs

    priceShared $scope
]
