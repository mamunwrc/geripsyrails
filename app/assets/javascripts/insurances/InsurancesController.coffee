insShared = ($scope) ->
  $scope.formTemplate = "insurances/_insurances-edit.html"
  $scope.editRoute = "insurance.edit({id: insurance.id})"
  $scope.sectionHome = "insurances"

  $scope.formDisabled = ->
    $scope.ctrl.insForm and $scope.ctrl.insForm.$invalid

  $scope.setCreateable 'Pat::Insurance'
  $scope.setUpdateable 'Pat::Insurance'

  $scope.setIncomingHpCode = ->
    $scope.insurance?.incoming_hp_code = $scope.insurance?.hp_id_code

wrapPayload = (payload) ->
  payload.state = payload.state?.name

geripsy.controller "InsurancesController", ['$scope', ($scope) ->
  $scope.sectionList = $scope.insurances = []
  $scope.showRoute = "insurance.show({id: item.id})"
  $scope.addRoute = "insurancesNew"
  $scope.title = "Insurance Provider List"

  $scope.listData ?= (provider) ->
    first: provider.name
    second: "INS" + _.map(new Array(3-provider.hp_id_code.toString().length), -> "0").join('') + provider.hp_id_code
    third: ''

  $scope.apiRoute = "insurances"
  insShared $scope
]

geripsy.controller "InsuranceController", [
  '$scope'
  '$stateParams'
  '$state'
  '$mdDialog'
  'Insurance'
  'insurance'
  ($scope, $stateParams, $state, $mdDialog, Insurance, insurance) ->
    $scope.isEditing = $state.current.data.isEditing
    $scope.insurance = insurance
    $scope.deleteable = true

    $scope.titleBar = =>
      insurance.name

    $scope.edit = -> $state.go 'insurance.edit', $stateParams, reload: true
    $scope.submit = ->
      wrapPayload $scope.insurance
      $scope.insurance.$update -> $state.go 'insurances'

    $scope.delete = (ev) ->
      confirm = $mdDialog.confirm()
        .title 'Irreversible action!'
        .textContent 'Are you SURE you want to delete this insurance provider? This action cannot be undone and may disturb other functionality in the system.'
        .ariaLabel 'confirm delete'
        .targetEvent ev
        .ok 'Yes, delete this insurance provider'
        .cancel 'Nevermind!'

      $mdDialog.show(confirm).then ->
        $scope.insurance.$delete ->
          $state.go 'insurances'
        , (response) ->
          console.log response
          $scope.Toast.display ["Could not delete insurance provider"]

    insShared $scope
]

geripsy.controller "InsuranceCreateController", [
  '$scope'
  '$state'
  'Insurance'
  ($scope, $state, Insurance) ->
    $scope.isEditing = true
    $scope.insurance = new Insurance
    $scope.titlebar = -> "Create new insurance provider"

    $scope.submit = ->
      wrapPayload $scope.insurance
      $scope.insurance.$save ->
        $state.go 'insurances'
      , (e) ->
        console.log e
        msgs = ["Insurance couldn't be saved:"]
        _.each e.data, (v,k) ->
          msgs.push [k, v[0]].join ": "
        $scope.Toast.display msgs

    insShared $scope
]
