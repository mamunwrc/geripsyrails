geripsy.controller "BillingController", [
  '$scope'
  '$rootScope'
  '$location'
  'Encounter'
  'Provider'
  'Practice'
  ($scope, $rootScope, $location, Encounter, Provider, Practice) ->
    $rootScope.printView = true

    getEncounters = (params, cb) ->
      params.no_pagination = true
      displayableEncs = (encs) ->
        _.filter encs, (enc) ->
          enc.certified and enc.service_date and enc.cpt_encounter_code isnt "TP"
         #and enc.encounter_type isnt "Psychotherapy untimed"
      Encounter.search params, (encounters) ->
        cb displayableEncs(encounters.data)

    query = $location.search()
    query.untimed = !!query.untimed
    $scope.printoutType = query.type or 'portrait'

    if $scope.printoutType is 'portrait'
      Provider.get {id: query.provider_ids}, (provider) ->
        $scope.provider = provider
        if query.patient_ids
          $scope.patients = _.filter provider.patients, (patient) ->
            _.includes _.flatten(Array(query.patient_ids)), String(patient.id)
        else
          $scope.patients = []

        # Lets just match up Patient#facility from globalPatients
        # instead of sending that data again over the wire
        #
        # first, wait for globalPatients to load...
        $scope.$watch 'globalPatients.patients', (val) ->
          return if not val or $scope.PATS_UPDATED

          $scope.PATS_UPDATED = true
          angular.forEach $scope.patients, (patient) ->
            if gpat = _.find $scope.globalPatients.patients, {id: patient.id}
              patient.facility = gpat.facility

        getEncounters
          simple: true
          'provider_ids[]': [provider.id]
          'patient_ids[]': _.map($scope.patients, 'id')
          from: query.from
          to: query.to
        , (encounters) ->
          encs = _.groupBy(encounters, 'patient_id')

          if $scope.patients.length
            _.each $scope.patients, (patient) ->
              patient.encounters = _.filter encs[patient.id], (enc) ->
                not enc.unbilled and
                enc.signer?.id is provider.id and
                enc.encounter_type isnt "Psychotherapy untimed"
          else
            $scope.patients = []
            _.each encs, (eGrp) ->
              pat = eGrp[0].patient
              pat.encounters = eGrp
              $scope.patients.push pat


    else
      Practice.get {id: query.practice_id}, (practice) ->
        $scope.facilities = if query.facility_ids
          _.filter practice.facilities, (facility) ->
            _.includes _.flatten(Array(query.facility_ids)), String(facility.id)
        else
          practice.facilities

        if query.provider_ids
          _.each $scope.facilities, (facility) ->
            facility.providers = _.filter facility.providers, (provider) ->
              _.includes _.flatten(Array(query.provider_ids)), String(provider.id)

          providerIds = query.provider_ids
        else
          providerIds = _($scope.facilities).map((facility) ->
            _.map facility.providers, 'id'
          ).flatten().uniq().value()
        #Facility.get {id: query.facility_ids}, (facility) ->
        #  console.log facility
        #  $scope.facility = facility
        #  if query.provider_ids
        #    $scope.providers = _.filter facility.providers, (provider) ->
        #      _.includes _.flatten(Array(query.provider_ids)), String(provider.id)
        #  else
        #    $scope.providers = facility.providers

        getEncounters
          simple: true
          'facility_ids[]': query.facility_ids
          'provider_ids[]': providerIds
          from: query.from
          to: query.to
          signed: 'Y'
        , (encounters) ->
          sortedEncs = _(encounters).reject('unbilled').sortBy('service_date').value()
          $scope.firstDate = _.first(sortedEncs)?.service_date
          $scope.lastDate = _.last(sortedEncs)?.service_date

          _.each $scope.facilities, (facility) ->
            _.each facility.providers, (provider) ->
              console.log sortedEncs[0]
              encs = _.filter sortedEncs, (enc) ->
                enc.signer?.id is provider.id and
                  enc.patient.facility_id is facility.id and
                  (query.untimed or enc.encounter_type isnt 'Psychotherapy untimed')

              encGroup = _(encs).groupBy('patient_id').values().value()
              provider.patients = _.map encGroup, (group) ->
                if (first = _.first(group)) and first.patient
                  patient = first.patient
                  retPat =
                    name: patient.full_name
                    dob: patient.dob
                    gender: patient.gender
                    insurance: patient.insurance

                  if first.diagnosis
                    retPat.dx = first.diagnosis.split("-")[0]

                  cptGroups = _.groupBy group, 'encounter_type'
                  retPat.service_dates = _.map cptGroups, (cptGroup) ->
                    first = _.first cptGroup
                    code = first.encounter_type
                    dates = _.map cptGroup, (enc) ->
                      service_date = momentu(enc.service_date).format 'l'

                      [m, d, y] = _.split service_date, '/'
                      {
                        year: Number(y[2..3])
                        month: Number(m)
                        day: Number(d)
                      }
                    dates = _.sortBy dates, ['year', 'month', 'day']

                    # slice off extraneous year/month
                    if dates[1] and _.every(dates, (d) -> d.year is dates[0].year)
                      withYear = dates.shift()
                      _.each dates, (d) -> delete(d.year)
                      dates.unshift withYear

                    dates = _.map(dates, (d) -> _.compact([d.month, d.day, d.year]).join('/')).join(', ')

                    [code, dates].join ': '

                  if _.find(group, (enc) -> enc.cpt_encounter_code is "90791")
                    retPat.name += "*"

                  retPat

              provider.patients = _.sortBy(provider.patients, (pat) -> _.last(pat.name.split(' ')))



]
