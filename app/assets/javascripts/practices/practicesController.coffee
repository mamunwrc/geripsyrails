practicesShared = ($scope) ->
  $scope.formTemplate = "practices/_practices-edit.html"
  $scope.editRoute = "practice.edit({id: practice.id})"
  $scope.sectionHome = "practices"

  $scope.formDisabled = ->
    $scope.ctrl.practiceForm and $scope.ctrl.practiceForm.$invalid

  $scope.setCreateable 'Adm::Practice'
  $scope.setUpdateable 'Adm::Practice'

wrapPayload = (payload) ->
  payload.practice_type = payload.practice_type.name
  payload.state = payload.state?.name

geripsy.controller "PracticesController", [
  '$scope'
  ($scope) ->
    $scope.sectionList = $scope.practices = []
    $scope.showRoute = "practice.show({id: item.id})"
    $scope.title = "Practice List"
    $scope.addRoute = "practicesNew"

    $scope.listData ?= (practice) ->
      first: practice.name
      second: 'second line'
      third: 'third line'

    $scope.apiRoute = "practices"

    practicesShared $scope
]

geripsy.controller "PracticeController", [
  '$scope'
  '$stateParams'
  '$state'
  '$httpParamSerializer'
  'practice'
  ($scope, $stateParams, $state, $httpParamSerializer, practice) ->
    $scope.isEditing = $state.current.data.isEditing
    $scope.practice = practice

    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing: " else "Viewing: "
      title + practice.name

    $scope.edit = -> $state.go 'practice.edit', $stateParams, {reload: true}
    $scope.submit = ->
      wrapPayload $scope.practice

      $scope.practice.$update ->
        $state.go 'practice.show', $stateParams, {reload: true}
      , (e) ->
        console.error e
        $scope.Toast.display ['Error saving practice']

    # BILLING PRINTOUT STUFF
    $scope.searchObj = {}
    $scope.facilities = practice.facilities
    $scope.filter = ->
      facilities = if _.isEmpty($scope.searchObj.facility)
        _.map(practice.facilities, 'id')
      else
        $scope.searchObj.facility

      params =
        practice_id: $scope.user.practice_id
        type: 'landscape'
        facility_ids: facilities
        from: $scope.searchObj.from
        to: $scope.searchObj.to

      $scope.billingUrl = ["/billing", $httpParamSerializer(params)].join("?")

    $scope.print = ->
      window.frames['billingcontent'].focus()
      window.frames['billingcontent'].print()
    $scope.selectAll = ->
      $scope.searchObj.facility = _.map($scope.facilities, 'id')
    # /BILLING PRINTOUT STUFF

    practicesShared $scope
]

geripsy.controller "PracticesCreateController", [
  '$scope'
  '$stateParams'
  '$state'
  'Practice'
  ($scope, $stateParams, $state, Practice) ->
    $scope.isEditing = true
    $scope.practice = new Practice
    $scope.titleBar = -> "Add practice"

    # default to solo practice
    $scope.practice.practice_type =
      val: "Solo"
      name: "solo"

    $scope.submit = ->
      wrapPayload $scope.practice
      $scope.practice.$save ->
        $state.go 'practices'
      , (e) ->
        console.error(e)
        $scope.Toast.display ['Error saving practice']

    practicesShared $scope
]
