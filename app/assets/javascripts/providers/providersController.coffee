providersShared = ($scope, ConfirmDateService, Provider) ->
  $scope.formTemplate = "providers/_providers-edit.html"
  $scope.editRoute = "providersEdit({id: provider.id})"
  $scope.sectionHome = "providers"
  $scope.providers  = []

  objectify = (collection, key, val) ->
    _.map collection, (item) ->
      keyname: item[key]
      keyvalue: item[val]

  if Provider
    Provider.query {simple: true}, (providers)->
      $scope.providers = objectify providers, 'id', 'full_name'

  if $scope.provider && $scope.provider.linked_provider
    $scope.provider.linked_provider = { val: $scope.provider.linked_provider.full_name, name: $scope.provider.linked_provider.id }

  $scope.wrapPayload = ->
    if hpid = $scope.provider.hp_account
      $scope.provider.hp_account = Number(String(hpid).replace(/p/i, ''))

    if userState = $scope.provider.user.state
      $scope.provider.user.state = userState.name

    if !!$scope.provider.linked_provider
      $scope.provider.linked_provider_id = $scope.provider.linked_provider.name
    else
      $scope.provider.linked_provider_id = null

    $scope.provider.patient_ids = _.map($scope.patientChips.groupPatients, 'id')
    $scope.provider.user_attributes = $scope.provider.user
    $scope.provider.licenses_attributes = $scope.provider.licenses
    _.each $scope.provider.licenses_attributes, (l) ->
      l.state = l.state.name
    $scope.provider.licenses_attributes = _.uniqBy($scope.provider.licenses_attributes, (l) -> l.name)
    $scope.provider.degree = $scope.provider.degree?.freetext or $scope.provider.degree?.val

    delete $scope.provider.user
    delete $scope.provider.licenses

  $scope.addLicense = ->
    $scope.provider.licenses ?= []
    $scope.provider.licenses.push {}

  $scope.formDisabled = ->
    $scope.ctrl.providerForm and $scope.ctrl.providerForm.$invalid

  $scope.pwreq = false
  $scope.rmLicense = () ->
    $scope.provider.licenses.splice @$index, 1

  $scope.confirmDates = () ->
    fields = _.map $scope.provider.licenses || [], (license) ->
      ["License##{license.number} Expiration", license.expiration]
    ConfirmDateService.confirm(fields)

  $scope.setupPatients = ->
    populatePatients = =>
      return if $scope.__patspopulated__
      $scope.__patspopulated__ = true
      $scope.patientChips.setPatientList _.filter($scope.globalPatients.patients, {status: 'active'})

    $scope.$watch 'globalPatients.patients', (val) ->
      populatePatients() if val

  degreeNames = [
    "PhD"
    "PsyD"
    "MD"
    "DO"
    "NP"
    "CNS"
    "MSW"
    "LCSW"
    "MA"
  ]

  $scope.degrees = _.map degreeNames, (deg) ->
    keyname: deg
    keyvalue: deg

  incidentToDegreeNames = [
    "LMSW"
    "LMHC"
    "LMFT"
    "LCSW"
  ]

  $scope.incidentToDegrees = _.map incidentToDegreeNames, (deg) ->
    keyname: deg
    keyvalue: deg

  @

geripsy.controller "ProvidersController", [
  '$scope'
  ($scope) ->
    $scope.sectionList = $scope.providers = []
    $scope.myProvider = {}
    $scope.showRoute = "provider.show({id: item.id})"
    $scope.addRoute = "providersNew"
    $scope.title = "Provider List"

    $scope.listData ?= (provider) ->
      firstAddendum = null
      if !!provider.linked_provider_id
        firstAddendum = "Incident To"
      {
        first: provider.full_name
        firstAddendum: firstAddendum
        second: provider.degree
        third: provider.npi
      }

    $scope.apiRoute = "providers?simple=true"

    providersShared $scope
    $scope.setCreateable 'Usr::Provider'
]

geripsy.controller "ProviderController", [
  '$scope'
  '$rootScope'
  '$stateParams'
  '$state'
  '$timeout'
  '$httpParamSerializer'
  'ConfirmDateService'
  'Provider'
  'provider'
  'PatientChipsService'
  ($scope, $rootScope, $stateParams, $state, $timeout, $httpParamSerializer, ConfirmDateService, Provider, provider, PatientChipsService) ->
    provider.patients = _.sortBy provider.patients, 'last_name'
    $scope.provider = provider
    $scope.patientChips = PatientChipsService.init(provider.patients)

    $scope.$watch 'globalPatients.patients', (val) ->
      return if not val or $scope.PATS_POPULATED

      $scope.PATS_POPULATED = true

      $scope.patients = _.map $rootScope.globalPatients.patients, (patient) ->
        patient.added = !!_.find provider.patients, id: patient.id
        patient.provider_names = _.map(patient.providers, 'full_name')
        patient

    # Fix all license expiration (should each be a Date)
    _.each $scope.provider.licenses || [], (license)->
      license.expiration = new Date(license.expiration)

    #### BILLING FILTER STUFF ####
    $scope.searchObj = {}
    $scope.filter = ->
      params =
        type: 'portrait'
        patient_ids: $scope.searchObj.patient
        provider_ids: $stateParams.id
        from: $scope.searchObj.from
        to: $scope.searchObj.to
      $scope.billingUrl = ["/billing", $httpParamSerializer(params)].join("?")
    $scope.print = ->
      window.frames['billingcontent'].focus()
      window.frames['billingcontent'].print()

    allSelected = false
    $scope.selectAll = ->
      $scope.searchObj.patient = if allSelected then [] else _.map($scope.provider.patients, 'id')
      allSelected = !allSelected
    #### END BILLING FILTER STUFF ####

    $scope.uniquelySorted = (strings) -> _.uniq(strings).sort()
    $scope.updatePatient = (patient) ->
      if patient.added
        Provider.add_patient {provider_id: $stateParams.id}, { id: patient.id}, (data)->
          console.log data
          $scope.Toast.display ["Success!"]
          patient.provider_names = $scope.uniquelySorted \
            [$scope.provider.full_name].concat(patient.provider_names || [])
        , (e) ->
          console.error e
          $scope.Toast.display ["Error: could not update provider/patient"]
          patient.added = false
      else
        Provider.rm_patient {provider_id: $stateParams.id, id: patient.id}, (data) ->
          console.log data
          $scope.Toast.display ["Success!"]
          patient.provider_names = $scope.uniquelySorted \
            _.difference(patient.provider_names || [], [$scope.provider.full_name])
        , (e) ->
          console.error e
          $scope.Toast.display ["Error: could not update provider/patient"]
          patient.added = true

    $scope.isEditing = $state.current.data.isEditing
    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing: " else "Viewing: "
      title + provider.fullName()

    $scope.edit = -> $state.go 'provider.edit', $stateParams, {reload: true}

    $scope.submit = ->
      $scope.confirmDates().then ->
        $scope.wrapPayload()
        $scope.provider.$update ->
          $state.go 'provider.show', $stateParams, {reload: true}
        , (e) ->
          $scope.Toast.display ["Could not update Provider"]

    providersShared $scope, ConfirmDateService, Provider

    $scope.setupPatients()
    $scope.setUpdateable 'Usr::Provider'

    $scope.arePatientsVisible = $scope.isEditing
    $scope.arePatientsLoading = false
    $scope.showAllPatients = ->
      $scope.arePatientsLoading = true
      $timeout (-> $scope.arePatientsVisible = true), 100
]

geripsy.controller "providersCreateController", [
  '$scope'
  '$stateParams'
  '$state'
  'ConfirmDateService'
  'Provider'
  'PatientChipsService'
  ($scope, $stateParams, $state, ConfirmDateService, Provider, PatientChipsService) ->
    $scope.isEditing = true
    $scope.provider = new Provider
    $scope.titleBar = -> "Add Provider"

    $scope.submit = ->
      $scope.confirmDates().then ->
        $scope.wrapPayload()
        console.log $scope.provider
        $scope.provider.$save ->
          $state.go 'providers'
        , (e) ->
          $scope.Toast.display ["Could not create Provider"]
          $scope.addLicense()

    $scope.patientChips = PatientChipsService.init()
    providersShared $scope, ConfirmDateService, Provider

    $scope.addLicense()
    $scope.pwreq = true

    $scope.setupPatients()
    $scope.setUpdateable 'Usr::Provider'
]
