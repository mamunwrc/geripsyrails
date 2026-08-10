grpEncShared = ($scope) ->
  $scope.formTemplate = "encounters/_encounters-edit.html"
  $scope.editRoute = "group_encounter.edit({id: encounter.id})"
  $scope.sectionHome = "group.show({id: encounter.group_id})"

geripsy.controller 'GroupEncounterCreateController', [
  '$scope'
  '$state'
  '$stateParams'
  '$mdDialog'
  'abilities'
  'Group'
  'GroupEncounter'
  ($scope, $state, $stateParams, $mdDialog, abilities, Group, GroupEncounter) ->
    abilities.can('Grp::Encounter', ['create']).then (val) ->
      unless val
        $scope.Toast.display ['You cannot create group notes']
        $state.go 'home', reload: true
      else
        Group.query (groups) ->
          # Need at least 2 patients to create a 90853
          groups = _.filter(groups, (group) -> group.patients.length >= 2)
          if groups.length
            groupPickerDialog =
              controller: ['$scope', '$mdDialog', ($scope, $mdDialog) ->
                $scope.close = ->
                  $mdDialog.hide($scope.groupId)

                $scope.groups = groups
                if $stateParams.gid
                  $scope.groupId = $stateParams.gid
              ]
              templateUrl: 'group_encounters/_group-picker-dialog-tmpl.html'
              clickOutsideToClose: false
              escapeToClose: false
            $mdDialog.show(groupPickerDialog).then (id) ->
              group = _.find groups, (g) -> g.id is id
              if group.unsigned_encounter
                $state.go 'group_encounter.edit',
                  group_id: id
                  id: group.unsigned_encounter.id
              else
                encounter = new GroupEncounter {group_id: id}
                encounter.$save (enc) ->
                  $state.go 'group_encounter.edit',
                    group_id: id
                    id: enc.id
          else
            $mdDialog.show(
              $mdDialog.confirm()
                .title 'No existing groups'
                .textContent 'You need to first add a group before you can proceed'
                .ariaLabel 'No Groups'
                .ok 'Add Group'
                .cancel 'View Groups'
            ).then(
              -> $state.go 'groupsNew'
            ,
              -> $state.go 'groups'
            )
    @
]

geripsy.controller 'GroupEncounterController', [
  '$scope'
  '$state'
  '$stateParams'
  '$mdDialog'
  '$q'
  'abilities'
  'GroupEncounter'
  'group'
  'EncounterFormSectionBuilderService'
  'EncounterValidations'
  'PatientNote'
  'ConfirmDateService'
  'EncounterDateService'
  ($scope, $state, $stateParams, $mdDialog, $q, abilities, GroupEncounter, group, EncFormBuilder, EncValidations, PatientNote, ConfirmDate, EncounterDateService) ->
    dateConverter = new EncounterDateService([['group_therapy_session', 'service_date']])
    setup = (group, skipEnc=false) ->
      $scope.group = group
      $scope.encounter = group.unsigned_encounter unless skipEnc
      $scope.patient_notes = group.unsigned_encounter.patient_notes
      $scope.patients = group.patients.map (patient) ->
        keyname: patient.id
        keyvalue: [patient.last_name, patient.first_name].join(", ")

      dateConverter.prepareEncDates $scope.encounter, !!$scope.encounter.signed_on

    setup group

    $scope.isEditing = $state.current.data.isEditing

    formSections = [
      name: 'session'
      number: 'I'
      heading: 'Group Therapy Session'
      partial: 'group_encounters/_group_encounter-session.html'
      fnid: 'session'
    ,
      name: 'interventions'
      number: 'II'
      heading: 'Interventions and Progress'
      partial: 'group_encounters/_group_encounter-interventions.html'
      fnid: 'interventions'
    ,
      name: 'certification'
      number: 'III'
      heading: 'Certification'
      locked: true
      partial: 'group_encounters/_group_encounter-certification.html'
      fnid: 'certification'
    ]

    $scope.formsec = EncFormBuilder.buildForm $scope, formSections,
      validations: [
        (encounter) ->
          EncValidations.buildValidation encounter, ->
            if @timeDiff() < 45
              @invalid("Minimum time for this note is 45 minutes")
            else
              @valid()

      ,
        (encounter) ->
          EncValidations.buildValidation encounter, ->
            patients = encounter.group_therapy_session.patients or []
            if patients.length > 1
              @valid()
            else
              @invalid "2 or more patients are required. Only #{patients.length} patients selected"


      ]

      beforeSave: ->
        $scope.encounter.certify = true
        $scope.encounter.certification.sign_date =
          momentu(new Date(), forceMidnight: true).toDate()
        $scope.encounter.provider_id = $scope.user.meta.id
        $scope.confirmDates()

      submit: ->
        $scope.persist().then (rs)->
          console.log rs
          if rs
            $state.go 'group.show', {id: $scope.group.id}
              .then -> $state.reload()

    $scope.submit = $scope.formsec.submit

    abilities.can('Grp::Encounter', ['update']).then (val) ->
      $scope.updateable = val
      # disallow non-providers from /edit
      if $state.is('group_encounter.edit') and not val
        $state.go 'group_encounter.show', reload: true

    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing " else "Viewing "
      title += "Note 90853 for Group #{group.name}"

    $scope.edit = ->
      $state.go('group_encounter.edit', $stateParams).then -> $state.reload()

    $scope.onSubmitFailure = (rs) =>
      message =
        if rs.status == 409
          "Encounter already certified"
        else
          rs.data || rs.errors || "#{rs.status} #{rs.statusText}"

      # Reset DOS if DOS invalid
      if rs.data?.date_of_service
        $scope.encounter.group_therapy_session.service_date = undefined
        $scope.formsec.sections.session.expanded = true
        $scope.formsec.sections.session.valid = false
        $scope.formsec.showErrors()
        $timeout ->
          $("gd-date[field-name='service_date'] md-datepicker").triggerHandler 'blur'
      $scope.Toast.display message
      $scope.encounter.certify = false
      $scope.formsec.submitted = false

    $scope.persist = (opts={}) ->
      if opts.uncertify
        $scope.encounter.certify = false
        $scope.encounter.certification?.sign_date = undefined

      dateConverter.convertDateFields $scope.encounter, (date) ->
        momentu(date).toDate().toJSON()

      if date = $scope.encounter.certification?.start_time
        $scope.encounter.certification.tz_offset_mins = moment(date).utcOffset()

      GroupEncounter.update({id: $scope.encounter.id, group_id: $scope.group.id}, $scope.encounter).$promise
        .then (group) ->
          setup(group) unless $scope.encounter.certify
          true
        .catch($scope.onSubmitFailure)

    $scope.confirmDates = ->
      ConfirmDate.validate
        dates: [
          label: 'Date of Service'
          date: $scope.encounter.group_therapy_session.service_date
          validation:
            msg: (resp) ->
              patIDs = resp.patients
              pats = _($scope.encounter.group_therapy_session.patients).filter( (pat) ->
                _.includes(resp.patients, pat.name)
              ).map('val').values()

              "Date of Service Duplicated for the following patients: #{pats.join('; ')}"
            fn: (date) ->
              defer = $q.defer()
              GroupEncounter.check_date {id: $scope.encounter.id, group_id: $scope.group.id, date: date}, (response) ->
                defer.resolve response

              defer.promise
        ]
        label: 'Yes, correct - approved for billing'
        validations: ['future']

    patNoteDialog = (note) ->
      controller: ['$scope', '$mdDialog', 'patients', ($scope, $mdDialog, patients) ->
        $scope.note = note
        $scope.patients = patients
        $scope.close = ->
          $mdDialog.hide($scope.note)
        $scope.delete = ->
          noteDialogCB('$delete')($scope.note, -> $mdDialog.cancel())
      ]
      controllerAs: 'ctrl'
      templateUrl: 'group_encounters/_patient-note-dialog-tmpl.html'
      clickOutsideToClose: true
      escapeToClose: true
      locals:
        patients: $scope.group.unsigned_encounter.group_therapy_session?.patients or []

    noteDialogCB = (meth) ->
      (note, cb) ->
        params = {group_id: group.id}
        params.id = note.id if note.id
        note[meth] params, (group) ->
          setup(group, true)
          cb() if cb # called when deleting record

    $scope.addNote = ->
      $mdDialog.show(patNoteDialog(new PatientNote $stateParams)).then noteDialogCB('$save')
    $scope.editNote = (note) ->
      PatientNote.get {group_id: group.id, id: note.id}, (patnote) ->
        patnote.incoming_patient_ids = _.map patnote.patients, 'id'
        $mdDialog.show( patNoteDialog(patnote) ).then noteDialogCB('$update')

    grpEncShared($scope)
    @
]
