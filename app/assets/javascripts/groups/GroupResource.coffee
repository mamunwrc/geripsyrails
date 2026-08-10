geripsy.factory 'Group', ['$resource', ($resource) ->
  $resource '/api/groups/:id',
    {id: '@id'}
    update:
      method: 'PATCH'
      headers: 'Content-Type': 'application/json'
]
