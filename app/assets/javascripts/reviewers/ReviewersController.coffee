reviewerShared = ($scope) ->
  $scope.formTemplate = "reviewers/_reviewers-edit.html"
  $scope.sectionHome = "reviewers"
  $scope.wrapPayload = ->
    $scope.reviewer.reviewer_type = $scope.reviewer.reviewer_type.name if $scope.reviewer.reviewer_type
    $scope.reviewer.user_attributes = $scope.reviewer.user
    delete $scope.reviewer.user

  $scope.formDisabled = ->
    $scope.ctrl.reviewerForm?.$invalid

  $scope.setCreateable 'Usr::Reviewer'
  $scope.setUpdateable 'Usr::Reviewer'

  $scope.reviewerTypes = [
      keyname: 'practice'
      keyvalue: 'Practice'
    ,
      keyname: 'facility'
      keyvalue: 'Facility'
    ,
      keyname: 'patient'
      keyvalue: 'Patient'
    ,
      keyname: 'provider'
      keyvalue: 'Provider'
  ]

  $scope.togglePatient = (pid) ->
    ap = $scope.reviewer.associated_patients
    idx = ap.indexOf pid
    if idx > -1
      ap.splice idx, 1
    else
      ap.push pid

  $scope.toggleObject = (collection, oid) ->
    idx = collection.indexOf oid
    if idx > -1
      collection.splice idx, 1
    else
      collection.push oid


geripsy.controller "ReviewersController", [
  '$scope'
  ($scope) ->
    $scope.sectionList = $scope.reviewers = []
    $scope.title = "reviewers List"
    $scope.showRoute = "reviewer.show({id: item.id})"
    $scope.addRoute = "reviewersNew"

    $scope.listData ?= (reviewer)->
      first: reviewer.user.full_name
      second: reviewer.user.email
      third: "Reviewer type: " + reviewer.reviewer_type?.name

    $scope.apiRoute = "reviewers"

    reviewerShared $scope
]

geripsy.controller "ReviewerController", [
  '$rootScope'
  '$scope'
  '$stateParams'
  '$state'
  '$mdDialog'
  'Reviewer'
  'reviewer'
  'facilities'
  'providers'
  ($rootScope, $scope, $stateParams, $state, $mdDialog, Reviewer, reviewer, facilities, providers) ->
    $scope.isEditing = $state.current.data.isEditing
    $scope.pwreq = false
    $scope.deleteable = true
    $scope.reviewer = reviewer
    $scope.titleBar = =>
      reviewer.user?.full_name

    $scope.facilities = facilities
    $scope.providers = providers

    $scope.edit = -> $state.go 'reviewer.edit', $stateParams, reload: true
    $scope.submit = ->
      $scope.wrapPayload()
      $scope.reviewer.$update ->
        $state.go 'reviewers'

    $scope.delete = (ev)->
      confirm = $mdDialog.confirm()
        .title 'Irreversible action!'
        .textContent 'Are you SURE you want to delete this reviewer?'
        .ariaLabel 'confirm delete'
        .targetEvent ev
        .ok 'Yes, delete reviewer'
        .cancel 'Nevermind!'

      $mdDialog.show(confirm).then ->
        $scope.reviewer.$delete ()->
          $state.go 'reviewers'
        , (response) ->
          console.log response
          $rootScope.Toast.display ["Could not delete Reviewer"]

    reviewerShared $scope
]

geripsy.controller "ReviewerCreateController", [
  '$scope'
  '$state'
  'Reviewer'
  'facilities'
  'providers'
  ($scope, $state, Reviewer, facilities, providers) ->
    $scope.isEditing = true
    $scope.pwreq = true
    $scope.reviewer = new Reviewer
    $scope.titlebar = -> "Create new Reviewer"
    $scope.facilities = facilities
    $scope.providers = providers

    # TODO learn how 2 ngresource constructorize...
    _.each ["facilities", "providers", "patients"], (type) ->
      $scope.reviewer["associated_#{type}"] = []

    $scope.submit = ->
      $scope.wrapPayload()
      $scope.reviewer.$save ->
        $state.go 'reviewers'
      , (e) ->
        console.error(e)

    reviewerShared $scope
]
