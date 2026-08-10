geripsy.factory 'PatientNote', ['$resource', ($resource) ->
  $resource '/api/groups/:group_id/patient_notes/:id',
    {group_id: '@group_id', id: '@id'}
    update:
      method: 'PATCH'
      headers: 'Content-Type': 'application/json'
]
