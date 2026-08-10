facilitiesShared = ($scope) ->
  $scope.formTemplate = "facilities/_facilities-edit.html"
  $scope.editRoute = "facility.edit({id: facility.id})"
  $scope.sectionHome = "facilities"

  $scope.formDisabled = ->
    $scope.ctrl.facilityForm and $scope.ctrl.facilityForm.$invalid

  $scope.setCreateable 'Adm::Facility'
  $scope.setUpdateable 'Adm::Facility'

wrapPayload = (payload) ->
  payload.state = payload.state?.name
  payload.medicare = payload.medicare?.name

geripsy.controller "FacilitiesController", [
  '$scope'
  ($scope) ->
    $scope.sectionList = $scope.facilities = []
    $scope.showRoute = "facility.show({id: item.id})"
    $scope.addRoute = "facilitiesNew"
    $scope.title = "facility List"

    $scope.listData ?= (facility) ->
      first: facility.name
      second: 'second line'
      third: 'third line'

    $scope.apiRoute = "facilities"

    facilitiesShared $scope
]

geripsy.controller "FacilityController", [
  '$scope'
  '$state'
  '$stateParams'
  '$httpParamSerializer'
  '$mdMedia'
  '$mdDialog'
  'facility'
  'facilityContactService'
  ($scope, $state, $stateParams, $httpParamSerializer, $mdMedia, $mdDialog, facility, facilityContactService) ->
    $state.go 'home' unless $scope.updateable
    $scope.isEditing = $state.current.data.isEditing
    $scope.facility = facility
    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing: " else "Viewing: "
      title + facility.name

    $scope.contacts = facility.facility_contacts
    fullScreen = $mdMedia('sm') or $mdMedia('xs')
    contactDialogOpts =
      controller: FacilityContactsEditController
      controllerAs: 'ctrl'
      templateUrl: "facilities/contacts/_facility-contact-edit.html"
      parent: angular.element document.body
      clickOutsideToClose: true
      fullscreen: fullScreen

    $scope.addContact = (ev) ->
      contactDialogOpts.targetEvent = ev
      contactDialogOpts.locals =
        contact: facilityContactService.create facility_id: facility.id
      $mdDialog.show contactDialogOpts
      .then (contact) ->
        $scope.contacts.push contact

    $scope.editContact = (contact, ev) ->
      contactDialogOpts.targetEvent = ev
      contactDialogOpts.locals =
        contact: angular.merge(new facilityContactService.FacilityContact, contact || {})
      $mdDialog.show contactDialogOpts
      .then (ctct, remove) ->
        if ctct.deleted
          $scope.contacts = _.reject $scope.contacts, {id: ctct.id}
        else
          cidx = _.findIndex $scope.contacts, {id: ctct.id}
          $scope.contacts[cidx] = ctct

    # BILLING PRINTOUT STUFF
    $scope.searchObj = {}
    $scope.providers = facility.providers
    $scope.filter = ->
      params =
        practice_id: $scope.user.practice_id
        type: 'landscape'
        facility_ids: [$stateParams.id]
        provider_ids: $scope.searchObj.provider
        from: $scope.searchObj.from
        to: $scope.searchObj.to

      params.untimed = 1 if $scope.searchObj.untimed

      $scope.billingUrl = ["/billing", $httpParamSerializer(params)].join("?")

    $scope.print = ->
      window.frames['billingcontent'].focus()
      window.frames['billingcontent'].print()
    $scope.selectAll = ->
      $scope.searchObj.provider = _.map($scope.providers, 'id')
    # /BILLING PRINTOUT STUFF

    $scope.edit = -> $state.go 'facility.edit', $stateParams, {reload: true}

    $scope.submit = ->
      wrapPayload $scope.facility

      $scope.facility.$update ->
        $state.go 'facility.show', $stateParams, {reload: true}
      , (e) ->
        $scope.Toast.display ["Could not update facility"]

    facilitiesShared $scope
]

geripsy.controller "FacilitiesCreateController", [
  '$scope'
  '$stateParams'
  '$state'
  'Facility'
  ($scope, $stateParams, $state, Facility) ->
    $scope.go 'home' unless $scope.createable
    $scope.isEditing = true
    $scope.facility = new Facility
    $scope.titleBar = -> "Add facility"

    $scope.submit = ->
      wrapPayload $scope.facility

      $scope.facility.$save ->
        $state.go 'facilities'
      , (e) ->
        $scope.Toast.display ["Could not create facility:", e.data.toString()]
        console.error(e)

    facilitiesShared $scope
]
