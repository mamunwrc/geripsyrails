geripsy.factory 'PatientChipsService', ->

  class PatientChipHandler
    constructor: (groupPatients) ->
      @selectedItem = null
      @searchText = null
      @groupPatients = groupPatients.map @formatter
      @allPatients = []

    query: (query) ->
      if query then @allPatients.filter(@filterFor(query)) else []

    formatter: (patient) ->
      name: [patient.first_name, patient.last_name].join(' ')
      dob: patient.dob
      id: patient.id

    filterFor: (query) ->
      downcase = angular.lowercase(query)
      (patient) ->
        angular.lowercase(patient.name).indexOf(downcase) isnt -1

    setPatientList: (patients) ->
      @allPatients = patients.map(@formatter)

  init: (groupPatients = []) ->
    new PatientChipHandler(groupPatients)
