geripsy.factory 'Price', ['$resource', ($resource) ->
  $resource '/api/prices/:id',
    {id: '@id'}
    update:
      method: 'PATCH'
      headers:
        'Content-Type': 'application/json'

    index:
      method: 'GET'
      url: '/api/prices'
      isArray: true
      headers:
        'Content-Type': 'application/json'

]
