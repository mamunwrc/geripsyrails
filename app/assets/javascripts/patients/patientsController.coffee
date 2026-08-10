patientsShared = ($scope, ConfirmDateService, cb) ->
  $scope.formTemplate = "patients/_patients-edit.html"
  $scope.sectionHome = "patients"

  $scope.formDisabled = ->
    $scope.ctrl.patientForm?.$invalid

  $scope.wrapParams = ->
    patient = $scope.myPatient
    patient.gender = patient.gender?.name
    patient.facility_id = patient.facility_id?.name
    patient.primary_provider_id = patient.primary_provider_id?.name
    patient.status = patient.status?.name
    patient.testing_provider_id = patient.testing_provider_id?.name
    if patient.incident_to_provider_id == 'NONE'
      patient.incident_to_provider_id = null

  $scope.confirmDates = ->
    #ConfirmDateService.confirm([['Date of Birth', $scope.myPatient.dob]])
    ConfirmDateService.validate
      dates: [{label: 'Date of Birth', date: $scope.myPatient.dob}]

  $scope.processInsurers = (insurances) ->
    insurances.unshift
      name: 'Medicare'
      hp_id_code: 999
    insurances.push
      name: 'PROVIDER NOT LISTED'
      hp_id_code: 404
    $scope.insurers = _.reject insurances, (ins) -> _.includes [1,2,47], ins.hp_id_code

  $scope.setCreateable 'Pat::Patient'
  $scope.setUpdateable 'Pat::Patient'

  $scope.insuranceTiers = [
    { tier: 'Primary', id: 'primary_insurance_id', number: 'primary_insurance_number' }
    { tier: 'Secondary', id: 'secondary_insurance_id', number: 'secondary_insurance_number' }
    { tier: 'Tertiary', id: 'tertiary_insurance_id', number: 'tertiary_insurance_number' }
  ]

  if $scope.isEditing
    $scope.$watchCollection '[myPatient.primary_insurance_id, myPatient.secondary_insurance_id, myPatient.tertiary_insurance_id]', (newvals, oldvals) ->
      fieldIdx = _.indexOf newvals, "NONE"
      return false if fieldIdx is -1

      fields = ['primary_insurance_id', 'secondary_insurance_id', 'tertiary_insurance_id']

      $scope.myPatient[fields[fieldIdx]] = null

geripsy.controller "PatientsController", [
  '$scope'
  '$filter'
  ($scope, $filter) ->
    $scope.sectionList = $scope.patients = []
    $scope.title = "Patient List"
    $scope.showRoute = "patient.show({id: patient.id})"
    $scope.addRoute = "patientsNew"
    $scope.listData ?= (patient) ->
      first: patient.full_name
      second: $filter('dateonly')(patient.dob)
      third: patient.gender?.val
    $scope.activeRoute = "patients?status=active"
    $scope.inactiveRoute = "patients?status=inactive"

    # reset pagination page back to 0 when switching tabs
    # TODO find a better pagination solution
    $scope.resetPagination = ->
      $scope.global.pagination.page = 0

    patientsShared $scope

    $scope.isIncidentToProvider = ->
      return !!$scope.user.meta.linked_provider_id
]

geripsy.controller "PatientsFilterController", [
  '$scope'
  'Facility'
  'Provider'
  'Patient'
  'Insurance'
  'Encounter'
  ($scope, Facility, Provider, Patient, Insurance, Encounter) ->
    angular.element('input.dd-search-filter').on('keydown', (ev) -> ev.stopPropagation())

    $scope.advancedSearch = false

    $scope.patients = []
    $scope.searchObj = {}
    $scope.facilities = []
    $scope.facility_pos_codes = []
    $scope.providers  = []
    $scope.insurances = []
    $scope.diagnoses = []
    $scope.incidentToProviders = []

    $scope.genders = [
      keyvalue: 'Male'
      keyname: 'male'
    ,
      keyvalue: 'Female'
      keyname: 'female'
    ,
      keyvalue: 'Unknown'
      keyname: 'unknown'
    ]

    $scope.statuses = [
      keyvalue: 'Active'
      keyname: 'active'
    ,
      keyvalue: 'Inactive'
      keyname: 'inactive'
    ,
      keyvalue: 'Deceased'
      keyname: 'deceased'
    ,
      keyvalue: 'Unknown'
      keyname: 'unknown'
    ]

    Provider.query {simple: true}, (providers) -> $scope.providers = $scope.helpers.objectify(providers, 'id', 'full_name')
    Provider.incident_to_providers (providers)-> $scope.incidentToProviders = $scope.helpers.objectify(providers, 'id', 'full_name')
    Facility.query {simple: true}, (facilities) -> $scope.facilities = $scope.helpers.objectify(facilities, 'id', 'name')
    Insurance.index {simple: true}, (insurances)->$scope.insurances = $scope.helpers.objectify(insurances, 'hp_id_code', 'name')
    Encounter.diagnoses (diagnoses)->$scope.diagnoses = _.map diagnoses, (diagnosis) ->
      keyname: diagnosis
      keyvalue: diagnosis
    Encounter.facility_pos_codes (facility_pos_codes)->$scope.facility_pos_codes = _.map facility_pos_codes, (facility_pos_code) ->
      keyname: facility_pos_code
      keyvalue: facility_pos_code

    $scope.export = ->
      console.log 'aoeuaoeuaoeu'
      $scope.filter 'filter'
    $scope.filter = (exportPDF=false)->
      extractVals = (collection) ->
        return unless collection
        _.map collection, 'name'

      params =
        simple: true
        'provider_ids[]': extractVals $scope.searchObj.provider
        'incident_to_provider_ids[]': extractVals $scope.searchObj.incidentToProviders
        'facility_ids[]': extractVals $scope.searchObj.facility
        'facility_pos_codes[]': extractVals $scope.searchObj.facility_pos_code
        'genders[]': extractVals $scope.searchObj.gender
        'diagnoses[]': extractVals $scope.searchObj.diagnosis
        'statuses[]': extractVals $scope.searchObj.status

      params.ssn = $scope.searchObj.ssn
      params.room_num = $scope.searchObj.room_num

      params.primary_insurance_id = $scope.searchObj.primary_insurance.name if $scope.searchObj.primary_insurance
      params.secondary_insurance_id = $scope.searchObj.secondary_insurance.name if $scope.searchObj.secondary_insurance

      params.from = $scope.searchObj.from if $scope.searchObj.from
      params.to = $scope.searchObj.to if $scope.searchObj.to

      params.birth_date_from = $scope.searchObj.birth_date_from if $scope.searchObj.birth_date_from
      params.birth_date_to = $scope.searchObj.birth_date_to if $scope.searchObj.birth_date_to

      if exportPDF
        window.location.href = $scope.exportURL + "&export_pdf=filter"
      else
        Patient.search params, (response) ->
          $scope.exportURL = response.export_url
          $scope.patients = _.map response.data, (patient) ->
            patient.dates = _.map(patient.service_dates, (date) -> momentu(date).format('l')).join ', '
            patient

]

geripsy.controller "PatientController", [
  '$scope'
  '$stateParams'
  '$state'
  '$rootScope'
  '$httpParamSerializer'
  '$mdDialog'
  'ConfirmDateService',
  'Encounter'
  'patient'
  'facilities'
  'abilities'
  'Insurance'
  'Provider'
  ($scope, $stateParams, $state, $rootScope, $httpParamSerializer, $mdDialog, ConfirmDateService, Encounter, patient, facilities, abilities, Insurance, Provider) ->
    $rootScope.globalPatients.updatePatient patient
    $scope.myPatient = patient
    $scope.myPatient.dob = momentu($scope.myPatient.dob).toDate()

    $scope.primaryProvider = $scope.myPatient.primary_provider_id?.name
    $scope.testings_list = [{keyvalue: 'None', keyname: 0}]

    $scope.incidentToProviders = []
    Provider.get {id: $scope.user.meta.id, simple: true}, (provider)->
      $scope.incidentToProviders = provider.incident_to_providers

    if $scope.primaryProvider
      Provider.testings_list {provider_id: $scope.primaryProvider}, (resp) ->
        _.each resp, (pro) ->
          $scope.testings_list.push {keyvalue: pro.full_name, keyname: pro.id}

    $scope.searchObj = {}
    Insurance.query {simple: true}, (insurances) ->
      $scope.processInsurers insurances
    $scope.filter = ->
      provider_id = $scope.searchObj.provider?.name
      return unless provider_id

      params =
        type: 'portrait'
        provider_ids: [provider_id]
        patient_ids: [$stateParams.id]
        from: $scope.searchObj.from
        to: $scope.searchObj.to

      $scope.billingUrl = ["/billing", $httpParamSerializer(params)].join("?")

    $scope.print = ->
      window.frames['billingcontent'].focus()
      window.frames['billingcontent'].print()

    $scope.facilities = _.map facilities, (facility) ->
      keyvalue: facility.name
      keyname: facility.id

    $scope.providers = _.map patient.providers, (provider) ->
      keyvalue: provider.full_name
      keyname: provider.id

    $scope.hasProviders = not _.isEmpty(patient.providers)
    $scope.posCodes = [31, 32]

    $scope.isEditing = $state.current.data.isEditing
    $scope.canSubmitNote = _.includes ["Usr::Admin", "Usr::Provider"], $scope.user.user_type

    $scope.edit = ->
      $state.go 'patient.edit', $stateParams, {reload: true}

    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing: " else "Viewing: "
      title += $scope.myPatient.fullName()

    $scope.submittingNote = ->
      ($scope.myPatient.note_text || '').trim().length > 0

    $scope.submitNote = ->
      return if ($scope.myPatient.newNoteText || '').trim().length == 0
      onSuccess = -> # noop
      onFailure = -> $scope.Toast.display ["Error: could not save note"]
      $scope.myPatient.note_text = $scope.myPatient.newNoteText
      $scope.myPatient.$addNote onSuccess, onFailure

    $scope.submit = ->
      $scope.confirmDates().then ->
        $scope.wrapParams()
        $scope.myPatient.$update ->
          $state.go 'patient.show', $stateParams, {reload: true}

    $scope.displayScreening = (ev, screening) ->
      screening = _.cloneDeep screening

      $mdDialog.show
        controller: ['$scope', '$mdDialog', 'ScreeningsService', ($scope, $mdDialog, screenings) ->
          $scope.hide = -> $mdDialog.hide()
          $scope.cancel = -> $mdDialog.cancel()
          $scope.screening = screening


          label = screenings[screening.screening_type]

          score = Math.floor _.sumBy(screening.axes, 'val') / screening.axes.length
          screening.axes.push
            val: score
            score: true

          angular.forEach screening.axes, (axis, idx) ->
            axis.label = label[idx].name
            axis.message = label[idx].labels[axis.val-1]

        ]
        templateUrl: 'patients/_patients-screening-dialog.html'
        parent: angular.element(document.body)
        targetEvent: ev
        clickOutsideToClose: true

    patientsShared $scope, ConfirmDateService
]

geripsy.controller "PatientsCreateController", [
  '$scope'
  '$rootScope'
  '$stateParams'
  '$state'
  '$mdDialog'
  'ConfirmDateService'
  'Patient'
  'facilities'
  'Insurance'
  'Provider'
  ($scope, $rootScope, $stateParams, $state, $mdDialog, ConfirmDateService, Patient, facilities, Insurance, Provider) ->
    Insurance.query {simple: true}, (insurances) ->
      $scope.processInsurers insurances
    $scope.myPatient = new Patient
    $scope.isEditing = true
    $scope.facilities = _.map facilities, (fac) ->
      keyvalue: fac.name
      keyname: fac.id

    $scope.incidentToProviders = []
    Provider.get {id: $scope.user.meta.id, simple: true}, (provider)->
      $scope.incidentToProviders = provider.incident_to_providers

    ##### Picker for duplicated patient name
    $scope.confirmNameDuplicate = (pats)->
      $mdDialog.show
        locals:
          patients: pats
        controller: ['$scope', '$mdDateLocale', 'patients', ($scope, $mdDateLocale, patients) ->
          $scope.patients = patients
          $scope.patientId = -1

          $scope.continue = ->
            if $scope.patientId is -1
              $mdDialog.cancel()
            else
              $state.go 'patient.edit', id: $scope.patientId, {reload: true}
              $mdDialog.hide()
        ]
        templateUrl: 'patients/_patients-existing-dialog.html'
        parent: angular.element(document.body)
        clickOutsideToClose: false
    ##### Picker for duplicated patient name

    $scope.checkNameConflict = (event)->
      element = event.target
      params =
        first_name: $scope.myPatient.first_name
        last_name: $scope.myPatient.last_name
      return if _.filter(params, _.isEmpty).length

      Patient.match params, (pats)->
        $scope.confirmNameDuplicate(pats) if pats.length
      , console.error

    $scope.submit = ->
      $scope.confirmDates().then ->
        $scope.wrapParams()
        $scope.myPatient.$save ->
          $rootScope.$broadcast 'populatePatientList'
          $state.go 'patients'
        , (e) ->
          console.error e
          $scope.Toast.display ["Error: could not create patient"]

    $scope.titleBar = -> 'Create New Patient'

    patientsShared $scope, ConfirmDateService
]

