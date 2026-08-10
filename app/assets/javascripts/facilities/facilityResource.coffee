geripsy.factory 'Facility', ['$resource', ($resource) ->
  $resource '/api/facilities/:id', 
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

]
