geripsy.service 'abilities', ['$http', ($http) ->
  abilityPromise = null

  getAbilities = ->
    if abilityPromise is null
      abilityPromise = $http.get('/api/abilities.json').then (data) ->
        data.data
      , (e)->
        console.error e
        abilityPromise = null

    abilityPromise

  retval =
    can: (model, levels) ->
      levels ?= []
      checkPermissions = (levels) ->
        _.chain(levels).flatten().includes(model).value()

      getAbilities().then (data) ->
        return unless data
        if _.isEmpty(levels) # check any
          for k,v of data.can
            levels.push k

        checkPermissions(_.map(levels, (level) -> data.can[level]))

    reset: ->
      abilityPromise = null
]

geripsy.controller 'applicationController', [
  '$rootScope'
  '$scope'
  '$window',
  '$state'
  '$timeout'
  'CONSTANTS'
  '$mdSidenav'
  '$mdDialog'
  '$mdMedia'
  '$location'
  'SessionStorage'
  'Auth'
  '$http'
  'Patient'
  'Encounter'
  'abilities'
  , ($rootScope, $scope, $window, $state, $timeout, CONSTANTS, $mdSidenav, $mdDialog, $mdMedia, $location, sessionStorage, Auth, $http, Patient, Encounter, abilities) ->
    Auth.currentUser().then (user)=>
      $scope.user = user
      Raven.setUserContext
        email: user.email
        id: user.id
    , (error) ->
      console.log error
      $state.go 'login'

    menus = [
        title: 'Home'
        link: 'home'
        icon: 'action:ic_home_24px'
        locked: true
      ,
        title: 'Patients'
        link: 'patients'
        icon: 'action:ic_face_24px'
        model: 'Pat::Patient'
        deny: ['Usr::Reviewer']
      ,
        title: 'Encounters'
        link: 'encounters'
        icon: 'editor:ic_insert_drive_file_24px'
        model: 'Enc::Encounter'
        deny: ['Usr::Reviewer']
      ,
        title: 'Encounters: filter'
        link: 'encountersFilter'
        icon: 'action:ic_search_24px'
        only: -> _.includes ["Usr::Provider", "Usr::Admin", "Usr::Reviewer"], $scope.user.user_type
      ,
        title: 'Patients: filter'
        link: 'patientsFilter'
        icon: 'action:ic_search_24px'
        only: -> _.includes ["Usr::Admin"], $scope.user.user_type
      ,
        title: 'Treatment plan: filter'
        link: 'treatmentPlanFilter'
        icon: 'action:ic_search_24px'
        only: -> _.includes ["Usr::Provider", "Usr::Admin", "Usr::Reviewer"], $scope.user.user_type
      ,
        title: 'Providers'
        link: 'providers'
        icon: 'maps:ic_local_hospital_24px'
        model: 'Usr::Provider'
        deny: ['Usr::Reviewer']
        only: -> _.includes ["Usr::Admin"], $scope.user.user_type
      ,
        title: 'Facilities'
        link: 'facilities'
        icon: 'social:ic_domain_24px'
        model: 'Adm::Facility'
        level: 'manage'
      ,
        title: 'Practices'
        link: 'practices'
        icon: 'social:ic_group_24px'
        model: 'Adm::Practice'
        deny: ['Usr::Reviewer']
      ,
        title: 'Admins'
        link: 'admins'
        icon: 'social:ic_person_24px'
        model: 'Usr::Admin'
      ,
        title: 'Reviewers'
        link: 'reviewers'
        icon: 'action:ic_assignment_ind_24px'
        model: 'Usr::Reviewer'
      ,
        title: 'Insurance'
        link: 'insurances'
        icon: 'hardware:ic_security_24px'
        model: 'Pat::Insurance'
        level: 'manage'
      ,
        title: 'CPT Prices'
        link: 'prices'
        icon: 'editor:ic_attach_money_24px'
        model: 'Pat::Insurance'
        level: 'manage'
      ,
        title: 'Therapy Groups'
        link: 'groups'
        icon: 'social:ic_people_outline_24px'
        model: 'Grp::Group'
        level: 'manage'
      ,
        title: 'Bookkeeping'
        link: 'bookkeeping'
        icon: 'communication:ic_email_24px'
        model: 'Pat::Insurance'
        level: 'manage'
      ,
        title: 'Claim MD Shipping'
        link: 'shipping'
        icon: 'communication:ic_rss_feed_24px'
        level: 'manage'
        deny: ['Usr::Reviewer']
        only: -> _.includes ["Usr::Admin"], $scope.user.user_type

    ]

    $scope.$on 'populatePatientList', ->
      $rootScope.globalPatients ?= {}

      # Don't load patient list if user has no Patient access
      return unless $scope.hasPatients

      # Don't load patient list if we are currently in progress
      return if $rootScope.globalPatients.LOADING

      $rootScope.globalPatients.LOADING = true
      $rootScope.globalPatients.currentPatient = {}

      Patient.query {simple: true}, (patients) ->
        $rootScope.globalPatients.patients = patients
        if patId = sessionStorage.get 'patientId'
          return if patId is $rootScope.globalPatients.currentPatient.id
          Patient.get {id: patId}, (pat) ->
              $rootScope.globalPatients.currentPatient = pat
              $rootScope.globalPatients.setPatient()
            ,
              (e) ->
                if patients.length
                  Patient.get {id: _.first(patients).id}, (pat) ->
                    $rootScope.globalPatients.currentPatient = pat
                    $rootScope.globalPatients.setPatient()
                else
                  sessionStorage.clear 'patientId'

        else if patients.length
          Patient.get {id: _.first(patients).id}, (pat) ->
            $rootScope.globalPatients.currentPatient = pat
            $rootScope.globalPatients.setPatient()

        $rootScope.globalPatients.LOADING = false

        $rootScope.$broadcast 'patientListPopulated'

    $scope.$on 'devise:login', (e, user) =>
      $scope.user = user
      Raven.setUserContext
        email: user.email
        id: user.id
      @setupAbilities()
      angular.element('input.dd-search-filter').on 'keydown', (ev) -> ev.stopPropagation()

    $scope.$on 'devise:logout', (e, user) =>
      $scope.user = {}
      @clearAbilities()
      delete $rootScope.globalPatients.patients
      delete $rootScope.globalPatients.currentPatient
      sessionStorage.clear 'patient'
      sessionStorage.clear 'patientId'
      
      if $state.current.name == "login" then $state.go 'login'
      else $window.location = $state.href("login")

    $scope.$on 'devise:unauthorized', (e, xhr, deferred) ->
      Auth.logout()

    $rootScope.$on '$stateChangeSuccess', (e, toState) =>
      $scope.currentSection =
        title: toState.data?.globalName

      clientVer = window.GERIPSY_VERSION
      serverVer = $rootScope.SERVER_VERSION

      if clientVer and serverVer and (clientVer isnt serverVer)
        console.log clientVer, serverVer, 'need to reload buster'
        reloadAlert = $mdDialog.alert
          title: 'New Version Available'
          textContent: 'There is a new version of the app available. Click "OK" to reload.'
          ok: 'OK'
        $mdDialog.show(reloadAlert).finally ->
          reloadAlert = undefined
          location.reload()



    $rootScope.$on '$stateChangeStart', (e, newState, newParams) ->
      # reset global search bar on state change
      if newParams.search and newState.name is 'patients'
        (($rootScope.global ?= {}).search ?= {}).filter = newParams.search
        $scope.showSearch = true
      else
        $rootScope.global?.search = ''
        $scope.showSearch = false
      return true if $scope.isAdmin()
      $rootScope.$broadcast 'populatePatientList' unless $rootScope.globalPatients?.patients?.length

    @speedDialOpened = false

    $scope.$watch 'appCtl.speedDialOpened', ->
      $timeout ->
        $scope.appCtl.tooltipsVisible = $scope.appCtl.speedDialOpened

    $scope.clearAbilities = ->
      can: []
      cannot: []

    $scope.abilities = $scope.clearAbilities()

    $scope.getAbilities = ->
      $http.get CONSTANTS.APIUrl + 'abilities.json'
        .then (resp) ->
          $scope.abilities = resp.data


    $scope.openSettings = (ev) ->
      $mdDialog.show
        controller: SettingsDialogController
        controllerAs: 'ctrl'
        templateUrl:  'shared/_settings-dialog.html'
        parent: angular.element document.body
        targetEvent: ev
        clickOutsideToClose: true
        fullscreen: $mdMedia('sm') or $mdMedia('xs')
      .then (resp) ->
        if resp.error
          msg = [resp.error, resp.msg].join ': '
          $scope.Toast.display [msg]
        else
          $scope.Toast.display ["User settings saved successfully"]

    $scope.logout = Auth.logout
    $scope.signedIn = Auth.isAuthenticated

    $scope.isAdmin = ->
      _.includes $scope.abilities.can.manage, 'Adm::Facility'

    $rootScope.globalPatients =
      currentPatient: {}
      enableNavigateOnSwitch: false

      navigateOnSwitch: () ->
        @enableNavigateOnSwitch = $state.current.name isnt 'encounters'

      switchPatient: () ->
        @setPatient()

        unless @enableNavigateOnSwitch
          $scope.closeSidenav()
        else
          @enableNavigateOnSwitch = false
          $state.go 'patient.show', {id: @currentPatient.id}, {reload: true}
            .then -> $scope.closeSidenav()

      setPatient: (id, broadcast = true) ->
        if id
          pat = _.find(@patients, {id: id})
          @currentPatient = pat
        if patient = @currentPatient
          sessionStorage.set 'patient', JSON.stringify(patient)
          sessionStorage.set 'patientId', patient.id

          if broadcast
            $rootScope.$broadcast 'patient-scope-changed', patient.id 

      updatePatient: (patient) ->
        return if @currentPatient is patient
        @currentPatient = patient
        @setPatient()

    @clearAbilities = ->
      abilities.reset()
      $scope.myMenus = []
      $scope.speedDialMenus = []

    @setupAbilities = ->
      $scope.myMenus = []
      $scope.speedDialMenus = []

      abilities.can("Pat::Patient").then (val) ->
        $scope.hasPatients = val
        $rootScope.$broadcast 'populatePatientList' if val


      _.each menus, (menu) ->
        if menu.deny and _.includes(menu.deny, $scope.user.user_type)
          return true
        if menu.locked
          $scope.myMenus.push menu
          return true
        if typeof menu.only is 'function'
          $scope.myMenus.push menu if menu.only()
          return true
        if menu.level
          abilities.can(menu.model, [menu.level]).then (val) ->
            $scope.myMenus.push menu if val
        else
          abilities.can(menu.model, []).then (val) ->
            $scope.myMenus.push menu if val

        abilities.can(menu.model, ['create']).then (val) ->
          $scope.speedDialMenus.push menu if val

    $scope.hasMenu = (title) ->
      _.find $scope.myMenus, link: title
    $scope.sdHasMenu = (title) ->
      _.find $scope.speedDialMenus, link: title
    $scope.setUpdateable = (model) ->
      abilities.can(model, ['update']).then (val) ->
        $scope.updateable = val
    $scope.setCreateable = (model) ->
      abilities.can(model, ['create']).then (val) ->
        console.log val
        $scope.createable = val

    $scope.toggleSidenav = (menuId = 'left') ->
      $mdSidenav(menuId).toggle()
    $scope.closeSidenav = (menuId = 'left') ->
      $mdSidenav(menuId).close()

    $rootScope.global = {}
    $scope.toggleSearch = =>
      $scope.global?.search = ''
      $scope.showSearch = !$scope.showSearch
      $scope.$broadcast("showingSearchNow")
      $location.search('search', undefined)

    $scope.toggleSearchOnEsc = (event) =>
      $scope.toggleSearch() if event.keyCode == 27

    $scope.applySearch = (event)=>
      search = ($scope.global.search.filter || "").trim()
      if search.length > 0
        $state.go 'patients', {search: search}, reload: true

    $rootScope.global.pagination =
      perPage: parseInt($location.search().perPage, 10) || 5
      page: parseInt($location.search().page, 10) || 0
      clientLimit: 10

    $rootScope.$watch 'global.pagination.page', (page) -> $location.search('page', page)
    $rootScope.$watch 'global.pagination.perPage', (page) -> $location.search('perPage', page)
    $rootScope.$on '$stateChangeStart', ->
      $rootScope.global.pagination.page = 0
    $rootScope.$on '$stateChangeSuccess', (e, toState) =>
      page = +$location.search().page
      perPage = +$location.search().perPage
      $rootScope.page = page if page >= 0
      $rootScope.perPage = perPage if perPage >= 0

]
