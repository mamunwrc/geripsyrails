grpShared = ($scope) ->
  $scope.formTemplate = "groups/_group-edit.html"
  $scope.editRoute = "group.edit({id: group.id})"
  $scope.sectionHome = "groups"

  $scope.formDisabled = ->
    $scope.ctrl.grpForm and $scope.ctrl.grpForm.$invalid

  $scope.setCreateable 'Grp::Group'
  $scope.setUpdateable 'Grp::Group'

  $scope.setupPatients = ->
    populatePatients = =>
      return if $scope.__patspopulated__
      $scope.__patspopulated__ = true
      $scope.patientChips.setPatientList _.filter($scope.globalPatients.patients, {status: 'active', has90791: true})

    $scope.$watch 'globalPatients.patients', (val) ->
      populatePatients() if val

  $scope.beforeSubmit = ->
    group = $scope.group
    group.group =
      name: group.name
      contact_email: group.contact_email
      contact_active: group.contact_active
      incoming_patient_ids: _.map($scope.patientChips.groupPatients, 'id')
    delete group.name
    delete group.contact_email
    delete group.contact_active

geripsy.controller 'GroupsController', ['$scope', ($scope) ->
  $scope.sectionList = $scope.groups = []
  $scope.showRoute = "group.show({id: item.id})"
  $scope.addRoute = "groupsNew"
  $scope.title = "Therapy Groups List"

  $scope.listData ?= (group) ->
    first: group.name
    second: "Patients in group: #{group.patients.length}"
    third: group.patients.map( (p) ->
      [p.first_name, p.last_name].join ' '
    ).join ', '

  $scope.apiRoute = "groups"
  grpShared $scope
]

geripsy.controller 'GroupController', [
  '$scope'
  '$stateParams'
  '$state'
  '$mdBottomSheet'
  'abilities'
  'Group'
  'group'
  'PatientChipsService'
  ($scope, $stateParams, $state, $mdBottomSheet, abilities, Group, group, PatientChipsService) ->
    canEncounter = false
    abilities.can 'Grp::Encounter', ['create']
      .then (val) ->
        console.log 'CANENCOUNTER = ', val, abilities
        canEncounter = $scope.canEncounter = val

    $scope.isEditing = $state.current.data.isEditing
    $scope.group = group
    $scope.titleBar = => group.name
    $scope.sessionsURL = "/api/groups/#{group.id}/encounters"
    $scope.sessionsTransform = (result, headers) ->
      _.filter result, 'certified'

    $scope.edit = -> $state.go 'group.edit', $stateParams, reload: true
    $scope.submit = =>
      $scope.beforeSubmit()
      $scope.group.$update -> $state.go 'group.show', $stateParams, reload: true

    $scope.patientChips = PatientChipsService.init(group.patients)

    $scope.showSession = (session) ->
      _session = session.group_therapy_session
      $mdBottomSheet.show
        templateUrl: 'groups/_session-data-tmpl.html'
        controller: [
          '$scope',
          '$mdBottomSheet',
          '$mdDialog',
          '$mdMedia',
          'GroupEncounter',
          ($scope, $mdBottomSheet, $mdDialog, $mdMedia, GroupEncounter) ->
            $scope.serviceDate = _session.service_date
            $scope.provider = session.signer
            $scope.patients = _.map _session.patients, 'val'
            $scope.canAddendum = canEncounter

            $scope.export = (ev, format='pdf') ->
              $mdDialog.show
                controller: EncounterExportDialogController
                controllerAs: 'ctrl'
                templateUrl: "encounters/_encounters-export-dialog.html"
                parent: angular.element document.body
                targetEvent: ev
                clickOutsideToClose: true
                fullscreen: $mdMedia('sm') or $mdMedia('xs')
              .then((type) ->
                $mdBottomSheet.hide
                  export: true
                  format: format
                  type: type
              , ->
                console.log 'dialog canceled'
              )

            $scope.submitAddendum = =>
              return false unless $scope.addendum?.text.length
              GroupEncounter.addendumize({
                group_id: session.group_id,
                id: session.id
              }, {
                addendum: $scope.addendum.text
              }, ->
                $scope.Toast.display ["Addendum added successfully"]
                $mdBottomSheet.hide export: false
              ,
                (resp) ->
                  $scope.Toast.display [resp.data.error]
                  $mdBottomSheet.hide export: false
              )

        ]
      .then (opts) ->
        console.log opts
        if opts.export
          location.href = "/api/groups/#{session.group_id}/encounters/#{session.id}.#{opts.format}?type=#{opts.type}"

    grpShared $scope

    $scope.setupPatients()

    @
]

geripsy.controller 'GroupCreateController', [
  '$scope'
  '$state'
  'Group'
  'PatientChipsService'
  ($scope, $state, Group, PatientChipsService) ->
    $scope.isEditing = true
    $scope.group = new Group
    $scope.titleBar = -> 'Create New Therapy Group'

    $scope.submit = ->
      $scope.beforeSubmit()
      $scope.group.$save ->
        $state.go 'groups'
      , (e) ->
        console.error e
        msgs = ["Therapy Group could not be saved:"]
        _.each e.data, (v,k) ->
          msgs.push [k, v[0]].join ': '
        $scope.Toast.display msgs

    $scope.patientChips = PatientChipsService.init()

    grpShared $scope

    $scope.setupPatients()

    @
]
