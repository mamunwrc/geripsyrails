adminShared = ($scope) ->
  $scope.formTemplate = "admins/_admins-edit.html"
  $scope.sectionHome = "admins"
  $scope.wrapPayload = ->
    $scope.admin.practice_id = $scope.admin.practice_id?.name
    $scope.admin.user_attributes = $scope.admin.user
    delete $scope.admin.user

  $scope.formDisabled = ->
    $scope.ctrl.adminForm?.$invalid

  $scope.pwreq = false

  $scope.setCreateable 'Usr::Admin'
  $scope.setUpdateable 'Usr::Admin'

geripsy.controller "AdminsController", [
  '$scope'
  ($scope, admins) ->
    $scope.sectionList = $scope.admins = []
    $scope.title = "Admins List"
    $scope.showRoute = "admin.show({id: item.id})"
    $scope.addRoute = "adminsNew"

    $scope.listData ?= (admin)->
      first: admin.user.full_name
      second: admin.user.email
      third: ''
    $scope.apiRoute = "admins"

    adminShared $scope
]

geripsy.controller "AdminController", [
  '$scope'
  '$stateParams'
  '$state'
  'Admin'
  'admin'
  'practices'
  ($scope, $stateParams, $state, Admin, admin, practices) ->
    $scope.isEditing = $state.current.data.isEditing
    $scope.admin = admin
    $scope.practiceList = _.map practices, (practice) ->
      keyname: practice.id
      keyvalue: practice.name

    $scope.titleBar = =>
      admin.user?.full_name

    $scope.edit = -> $state.go 'admin.edit', $stateParams, reload: true
    $scope.submit = ->
      $scope.wrapPayload()
      $scope.admin.$update ->
        $state.go 'admins'

    adminShared $scope
]

geripsy.controller "AdminCreateController", [
  '$scope'
  '$state'
  'Admin'
  'practices'
  ($scope, $state, Admin, practices) ->
    $scope.isEditing = true
    $scope.pwreq = true
    $scope.admin = new Admin
    $scope.titlebar = -> "Create new Admin"
    $scope.practiceList = _.map practices, (practice) ->
      keyname: practice.id
      keyvalue: practice.name

    $scope.submit = ->
      $scope.wrapPayload()
      $scope.admin.$save ->
        $state.go 'admins'
      , (e) ->
        console.log e
        msgs = ["Admin couldn't be saved:"]
        _.each e.data, (v,k) ->
          msgs.push [k, v[0]].join ": "
        $scope.Toast.display msgs

    adminShared $scope
]
