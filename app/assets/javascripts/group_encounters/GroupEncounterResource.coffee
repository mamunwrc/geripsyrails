geripsy.factory 'GroupEncounter', ['$resource', ($resource) ->
  $resource '/api/groups/:group_id/encounters/:id',
    {group_id: '@group_id', id: '@id'}
    update:
      method: 'PATCH'
      headers: 'Content-Type': 'application/json'

    check_date:
      url: '/api/groups/:group_id/encounters/:id/check_date'
      method: 'GET'

    addendumize:
      url: '/api/groups/:group_id/encounters/:id/addendumize'
      method: 'PATCH'

]
