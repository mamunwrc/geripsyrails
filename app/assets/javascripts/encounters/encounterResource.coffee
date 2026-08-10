geripsy.factory 'Encounter', ['$resource', ($resource) ->
  $resource '/api/patients/:patient_id/encounters/:id', 
    {patient_id: '@patient_id', id: '@id'}
    update:
      method: 'PATCH'
      headers: 
        'Content-Type': 'application/json'

    certs:
      method: 'GET'
      url: '/api/encounters/certs'

    diagnoses:
      method: 'GET'
      url: '/api/encounters/diagnoses'
      isArray: true

    facility_pos_codes:
      method: 'GET'
      url: '/api/encounters/facility_pos_codes'
      isArray: true

    md_names:
      method: 'GET'
      url: '/api/encounters/md_names'
      isArray: true

    search:
      method: 'GET'
      url: '/api/encounters'
      transformResponse: (data, headers) ->
        res =
          data: angular.fromJson(data)
          export_url: headers('x-export-url')

        res

    treatment_plan:
      method: 'GET'
      url: '/api/patients/:patient_id/treatment_plan'

    dates:
      method: 'GET'
      url: '/api/patients/:patient_id/encounter_dates'
      isArray: true

    dup_check:
      method: 'GET'
      url: '/api/patients/:patient_id/check_service_date'
]
