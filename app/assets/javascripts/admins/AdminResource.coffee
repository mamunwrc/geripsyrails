geripsy.factory 'Admin', ['$resource', ($resource) ->
  _resource = $resource '/api/admins/:id', 
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

]
