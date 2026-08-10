geripsy.factory 'routeCBs', ['ToastService', '$state', (Toast, $state) ->
  good = -> console.log 'success!'
  bad = (e) ->
    console.error(e)
    Toast.display ["Cannot access page: #{e.statusText}"]
    $state.go 'home'

  return {
    good: good
    bad: bad
  }
]

geripsy.factory 'resourceObj', [
  'routeCBs'
  (cbs) ->
    return {
      query: (resource, opts) ->
        opts ?= {}
        resource.query(opts, cbs.good, cbs.bad).$promise

      get: (resource, params) =>
        resource.get(params, cbs.good, cbs.bad).$promise
    }
]

geripsy.config [
  "$stateProvider"
  "$urlRouterProvider"
  "$locationProvider"
  "CONSTANTS"
  ($stateProvider, $urlRouterProvider, $locationProvider, CONSTANTS) ->
    $stateProvider.state 'home',
      url: '/home'
      templateUrl: 'home/_home.html'
      controller: 'HomeCtrl'
      data:
        globalName: 'Home'

    .state 'billing',
      url: '/billing'
      views:
        print:
          templateUrl: 'shared/_billing.html'
          controller: 'BillingController as ctrl'

    .state CONSTANTS.RoutingStates.PATIENT,
      url: "/patients?search"
      templateUrl: 'patients/_patients-list.html'
      controller: 'PatientsController as ctrl'
      data:
        globalName: 'Patients'

    .state 'patientsFilter',
      url: '/patients/filter'
      controller: 'PatientsFilterController as ctrl'
      templateUrl: 'patients/_patients-filter.html'
      data:
        globalName: 'Patients'

    .state 'patientsNew',
      url: "/patients/new"
      templateUrl: 'shared/_edit-base.html'
      controller: 'PatientsCreateController as ctrl'
      data:
        globalName: 'Patients'
      resolve:
        facilities: ['resourceObj', 'Facility', (res, Facility) -> res.query Facility, {simple: true}]

    .state 'patient',
      url: '/patients/:id'
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      resolve:
        patient: ['resourceObj', '$stateParams', 'Patient', (res, $stateParams, Patient) ->
          res.get(Patient, $stateParams)
        ]
        facilities: ['resourceObj', 'Facility', (res, Facility) -> res.query Facility, {simple: true}]
      controller: "PatientController as ctrl"
      data:
        globalName: 'Patients'
    .state 'patient.show',
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state 'patient.edit',
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state CONSTANTS.RoutingStates.PROVIDER,
      url: '/providers'
      templateUrl: 'shared/_list-base.html'
      controller: 'ProvidersController as ctrl'
      data:
        globalName: 'Providers'

    .state 'providersNew',
      url: '/providers/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'providersCreateController'
      controllerAs: 'ctrl'
      data:
        globalName: 'Providers'

    .state 'provider',
      url: '/providers/:id'
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      controller: "ProviderController as ctrl"
      resolve:
        provider: ['$stateParams', 'resourceObj', 'Provider', ($stateParams, res, Provider) ->
          res.get Provider, $stateParams
        ]
        #patients: ['resourceObj', 'Patient', (res, Patient) -> res.query Patient, {simple: true}]
      data:
        globalName: 'Providers'
    .state 'provider.show',
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state 'provider.edit',
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state CONSTANTS.RoutingStates.ENCOUNTER,
      url: '/encounters'
      templateUrl: 'encounters/_encounters-list.html'
      controller: 'encountersController as ctrl'
      resolve:
        # encounters: ['$stateParams', 'routeCBs', 'Encounter', 'patient', ($stateParams, cbs, Encounter, patient) ->
        #   Encounter.query(patient_id: patient.id, cbs.good, cbs.bad).$promise
        # ]
        patient: ['Patient', 'SessionStorage', 'resourceObj', (Patient, SessionStorage, res) ->
          pid = SessionStorage.get 'patientId'
          res.get Patient,
            id: pid
        ]
      data:
        globalName: 'Encounters'

    .state 'encountersFilter',
      url: '/encounters/filter'
      controller: 'encountersFilterController as ctrl'
      templateUrl: 'encounters/_encounters-filter.html'
      data:
        globalName: 'Encounters'

    .state 'treatmentPlanFilter',
      url: '/encounters/treatment-plan-filter'
      controller: 'encountersFilterController as ctrl'
      templateUrl: 'encounters/_encounters-filter.html'
      data:
        globalName: 'Treatment Plans'
        treatmentPlan: true

    .state "encountersNew",
      url: '/encounters/new?enc_type'
      params:
        encounterType: null
      templateUrl: 'shared/_edit-base.html'
      controller: 'encountersCreateController'
      controllerAs: 'ctrl'
      resolve:
        encounter: ['Encounter', (Encounter) -> new Encounter]
        treatment_plan: ['$stateParams', 'SessionStorage', 'Encounter', ($stateParams, SessionStorage, Encounter) ->
          if $stateParams.enc_type is 'TP'
            Encounter.treatment_plan({ patient_id: SessionStorage.get('patientId') }).$promise
          else
            {}
        ]
      data:
        globalName: 'Encounters'

    .state "encountersApi",
    url: '/api/patients/:patient_id/encounters/:id'

    .state "encountersApi.serviceTimestamp",
    url: '/service_timestamp'

    .state "encountersApi.shipClaimMd",
    url: '/ship_claim_md'

    .state "encountersCanManage",
    url: '/api/encounters/can_manage'

    .state "encounter",
      abstract: true
      url: '/encounters/:id'
      controller: 'encounterController as ctrl'
      template: '<div ui-view layout="column" flex></div>'
      resolve:
        encounter: [
          '$stateParams'
          'SessionStorage'
          'resourceObj'
          'Encounter'
          ($stateParams, session, res, Encounter) ->
            patId = JSON.parse(session.get('patient'))?.id
            console.log patId

            # defaulting patient id to 0 to always throw a 404 (403?) if super admin is making request
            patId ?= 0
            params =
              id: $stateParams.id
              patient_id: patId
            res.get Encounter, params
        ]
      data:
        globalName: 'Encounters'
    .state "encounter.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false

    .state "encounter.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state "encounter.editServiceDate",
      url: '/service_date'
      templateUrl: 'encounters/_encounters-edit-service-timestamp.html'

    .state "encounter.editServiceTime",
      url: '/service_time'
      templateUrl: 'encounters/_encounters-edit-service-timestamp.html'

    .state "encounter.print",
      controller: 'encountersPrintController as ctrl'
      url: '/print'
      templateUrl: 'encounters/_encounters-print.html'
      data:
        isEditing: false

    .state "encountersPrintContent",
      url: '/encounters/:id/print_content'
      views:
        print:
          templateUrl: 'encounters/_encounters-print-content.html'
          controller: 'encountersPrintController'
          controllerAs: 'ctrl'
      resolve:
        encounter: ['$stateParams', 'SessionStorage', 'resourceObj', 'Encounter', ($stateParams, session, res, Encounter) ->
          patId = session.get('patientId')

          # see encounter
          patId ?= 0
          params =
            id: $stateParams.id
            patient_id: patId

          res.get Encounter, params
        ]

    .state 'practices',
      url: '/practices'
      templateUrl: 'shared/_list-base.html'
      controller: 'PracticesController as ctrl'
      data:
        globalName: 'Practices'

    .state "practicesNew",
      url: '/practices/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'PracticesCreateController as ctrl'
      data:
        globalName: 'Practices'

    .state 'practice',
      url: '/practice/:id'
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      resolve:
        practice: ['$stateParams', 'resourceObj', 'Practice', ($stateParams, res, Practice) ->
          res.get Practice, $stateParams
        ]
      controller: "PracticeController as ctrl"
      data:
        globalName: 'Practices'
    .state 'practice.show',
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state 'practice.edit',
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'facilities',
      url: '/facilities'
      templateUrl: 'shared/_list-base.html'
      controller: 'FacilitiesController as ctrl'
      data:
        globalName: 'Facilities'

    .state "facilitiesNew",
      url: '/facilities/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'FacilitiesCreateController'
      controllerAs: 'ctrl'
      data:
        globalName: 'Facilities'

    .state "facility",
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      url: '/facilities/:id'
      controller: 'FacilityController as ctrl'

      resolve:
        facility: ['$stateParams', 'resourceObj', 'Facility', ($stateParams, res, Facility) ->
          res.get Facility, $stateParams
        ]
      data:
        globalName: 'Facilities'
    .state "facility.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "facility.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state "admins",
      url: '/admins'
      templateUrl: 'shared/_list-base.html'
      controller: 'AdminsController as ctrl'
      data:
        globalName: 'Admins'

    .state "adminsNew",
      url: '/admins/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'AdminCreateController as ctrl'
      resolve:
        practices: ['resourceObj', 'Practice', (res, Practice) -> res.query Practice, {simple: true}]
      data:
        globalName: 'Admins'

    .state "admin",
      abstract: true
      url: '/admins/:id'
      template: '<div ui-view layout="column" flex></div>'
      controller: 'AdminController as ctrl'
      resolve:
        admin: ['$stateParams', 'resourceObj', 'Admin', ($stateParams, res, Admin) -> res.get Admin, $stateParams]
        practices: ['resourceObj', 'Practice', (res, Practice) -> res.query Practice, {simple: true} ]
      data:
        globalName: 'Admins'
    .state "admin.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "admin.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state "reviewers",
      url: '/reviewers'
      templateUrl: 'shared/_list-base.html'
      controller: 'ReviewersController as ctrl'
      data:
        globalName: 'Reviewers'

    .state "reviewersNew",
      url: '/reviewers/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'ReviewerCreateController as ctrl'
      data:
        globalName: 'Reviewers'
      resolve:
        facilities: ['resourceObj', 'Facility', (res, Facility) -> res.query Facility, {simple: true}]
        providers: ['resourceObj', 'Provider', (res, Provider) -> res.query Provider, {simple: true}]

    .state "reviewer",
      abstract: true
      url: '/reviewers/:id'
      template: '<div ui-view layout="column" flex></div>'
      controller: 'ReviewerController as ctrl'
      resolve:
        reviewer: ['$stateParams', 'resourceObj', 'Reviewer', ($stateParams, res, Reviewer) -> res.get Reviewer, $stateParams]
        facilities: ['resourceObj', 'Facility', (res, Facility) -> res.query Facility, {simple: true}]
        providers: ['resourceObj', 'Provider', (res, Provider) -> res.query Provider, {simple: true}]
      data:
        globalName: 'Reviewers'
    .state "reviewer.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "reviewer.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'insurances',
      url: '/insurances'
      templateUrl: 'shared/_list-base.html'
      controller: 'InsurancesController as ctrl'
      data:
        globalName: 'Insurance Providers'

    .state "insurancesNew",
      url: '/insurances/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'InsuranceCreateController'
      controllerAs: 'ctrl'
      data:
        globalName: 'Insurance Providers'

    .state "insurance",
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      url: '/insurances/:id'
      controller: 'InsuranceController as ctrl'

      resolve:
        insurance: ['$stateParams', 'resourceObj', 'Insurance', ($stateParams, res, Insurance) ->
          res.get Insurance, $stateParams
        ]
      data:
        globalName: 'Insurance Providers'
    .state "insurance.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "insurance.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'prices',
      url: '/prices'
      templateUrl: 'shared/_list-base.html'
      controller: 'PricesController as ctrl'
      data:
        globalName: 'CPT Prices'

    .state "pricesNew",
      url: '/prices/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'PriceCreateController'
      controllerAs: 'ctrl'
      data:
        globalName: 'CPT Prices'

    .state "price",
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      url: '/prices/:id'
      controller: 'PriceController as ctrl'

      resolve:
        price: ['$stateParams', 'resourceObj', 'Price', ($stateParams, res, Price) ->
          res.get Price, $stateParams
        ]
      data:
        globalName: 'CPT Prices'
    .state "price.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "price.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'bookkeeping',
      url: '/bookkeeping'
      templateUrl: 'bookkeeping/_bookkeeping-index.html'
      controller: 'BookkeepingController as ctrl'
      data:
        globalName: 'Bookkeeping Email'

    .state 'shipping',
      url: '/shipping'
      templateUrl: 'shipping/_shipping-index.html'
      controller: 'ShippingController as ctrl'
      data:
        globalName: 'Claim MD Shipping'

    .state "groupsNew",
      url: '/groups/new'
      templateUrl: 'shared/_edit-base.html'
      controller: 'GroupCreateController'
      controllerAs: 'ctrl'
      data:
        globalName: 'Therapy Group'
    .state 'groups',
      url: '/groups'
      templateUrl: 'shared/_list-base.html'
      controller: 'GroupsController as ctrl'
      data:
        globalName: 'Therapy Groups'
    .state "group",
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      url: '/groups/:id'
      controller: 'GroupController as ctrl'

      resolve:
        group: ['$stateParams', 'resourceObj', 'Group', ($stateParams, res, Group) ->
          res.get Group, $stateParams
        ]
      data:
        globalName: 'Therapy Group'
    .state "group.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "group.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'newGroupEncounter',
      url: '/group_encounters/new?gid'
      templateUrl: 'shared/_edit-base.html'
      controller: 'GroupEncounterCreateController as ctrl'
      data:
        globalName: 'Encounters'
    .state "group_encounter",
      abstract: true
      template: '<div ui-view layout="column" flex></div>'
      url: '/groups/:group_id/encounter'
      controller: 'GroupEncounterController as ctrl'
      resolve:
        group: ['$stateParams', 'resourceObj', 'Group', ($stateParams, res, Group) ->
          res.get Group, id: $stateParams.group_id
        ]
      data:
        globalName: 'Group Encounter'
    .state "group_encounter.show",
      url: ''
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: false
    .state "group_encounter.edit",
      url: '/edit'
      templateUrl: 'shared/_edit-base.html'
      data:
        isEditing: true

    .state 'login',
      url: '/login'
      templateUrl: 'auth/_sign-in.html'
      controller: 'authCtrl'
      onEnter: ['$state', 'Auth', ($state, Auth) ->
        Auth.currentUser().then ->
          $state.go 'home'
      ]


    $urlRouterProvider.otherwise '/home'

    $locationProvider.html5Mode true
]

